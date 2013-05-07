#encoding: utf-8
#获取淘宝所有在线商品
class TaobaoItemsOnsale
  GET_SIZE = 100
  attr_accessor :nick,:responsed,:products,:total_results,:products,:account
  @remember = false
  
  def initialize(account)
    @page_no        = 1
    @account        = account
    @trade_source   = @account.trade_source
    @nick           = @account.key == "nippon " ? '立邦漆官方旗舰店'  : @trade_source.name
    @responsed      = get_products(@nick,@page_no,@trade_source.id)
    @total_results  = get_total_results
    @products       = get_items rescue raise("没有找到商品")
  end
  
  def products
    return @products if @remember 
    @pages = @total_results / GET_SIZE + (@total_results % GET_SIZE == 0 ? 0 : 1)
    
    @pages.times do |page|
      @responsed = get_products(@nick,@page_no+=1,@trade_source.id)
      @products += get_items if @page_no <= @pages
    end
    
    @remember = true
    @products = @products.collect {|item| TaobaoItemProduct.new(item,@nick,@account.id,@trade_source.id) }
  end
  
  def fetch
    @products = TaobaoItemsOnsale.new(@account).products
  end

  def get_products(nick,page_no,trade_source_id)
    TaobaoQuery.get({method: 'taobao.items.onsale.get', fields: 'num_iid,num,detail_url,title,sku.properties_name,sku.properties,sku.quantity, sku.sku_id, outer_id, product_id, pic_url,cid,price,cat_name', nick: nick, page_size: GET_SIZE, page_no: page_no}, trade_source_id)
  end

  def get_items
    get_attributes["items"]["item"]
  end

  def get_attributes
    @responsed["items_onsale_get_response"]
  end

  def get_total_results
    get_attributes["total_results"]
  end
end


class TaobaoItemProduct
  delegate :num_iid,:outer_id,:num,:detail_url,:title,:skus, :product_id, :pic_url,:cid,:price,:to => :struct_product
  attr_accessor :attrs,:responsed
  def initialize(attrs,nick,account_id,trade_source_id)
    @account_id       = account_id
    @attrs            = attrs
    @trade_source_id  = trade_source_id
    @nick             = nick
    @taobao_skus     =  taobao_skus if taobao_skus.present?
  end
  
  def get_item
    @responsed = TaobaoQuery.get({method: 'taobao.item.get',  fields: 'sku', num_iid: num_iid, nick: @nick}, @trade_source_id)
  end

  def get_skus
    @skus ||= get_item['item_get_response']['item']['skus']['sku'] rescue []
  end
  
  def parse_attrs(args=[])
    @parse_attrs = @attrs.dup
    @parse_attrs.slice!(*args)                            if args.present?
    @parse_attrs["cid"] = @parse_attrs["cid"].to_s        if @parse_attrs["cid"].present?
    @parse_attrs.merge!({"account_id" => @account_id,"name" => @parse_attrs.delete("title")})
    @parse_attrs.except("num")
  end
  
  def taobao_skus
    prefix_skus     = {:account_id => @account_id,:num_iid => num_iid.to_s }
    @taobao_skus  ||= get_skus.collect {|taobao_sku| OpenStruct.new(taobao_sku.merge!(prefix_skus))}
  end
  
  def insert!
    new_product = CompareProduct::ChangeStat.new
    new_product.upgrade(self,[])
    new_product.save!
  end
  
  private
  def struct_product
    OpenStruct.new(@attrs)
  end
end


#   对比本地商品有无更新
#   有商品变更则创建变更记录  
#   本地无商品则创建
class CompareProduct
  attr_accessor :account,:num_iids,:onsale,:changes
  def initialize(account)
    @account      = account
    @onsale       = TaobaoItemsOnsale.new(account)
    @products     = @onsale.products
    @num_iids     = @products.map(&:num_iid)
    @changes    ||= changes_products
  end
  
  def have_exists_num_ids
    exists_taobao_products.pluck(:num_iid)
  end
  
  def not_exists_num_ids
    num_iids - have_exists_num_ids
  end
  
  def have_exists
    @have_exists ||= @products.select { |v| have_exists_num_ids.include?(v.num_iid) }
  end
  
  def not_exists
    @not_exists ||= @products.select {|v| not_exists_num_ids.include?(v.num_iid)}
  end
  
  def exists_taobao_products
    @exists_taobao_products ||= ChangeStat.where(:num_iid => @num_iids,:account_id => @account.id).includes(:taobao_skus)
  end
  
  def changes_products
    have_exists.each do |taobao_onsale_product| 
      exists_taobao_products.tap do |taobao_products|
        taobao_products.each {|taobao_product| taobao_product.upgrade(taobao_onsale_product,taobao_products) }
      end
    end
    exists_taobao_products.select {|taobao_product| taobao_product.changed? || taobao_product.taobao_skus.any? {|taobao_sku| taobao_sku.new_record? || taobao_sku.changed?} }
  end
  
  class ChangeStat < TaobaoProduct
    
    def upgrade(taobao_onsale_product,taobao_products)
      self.attributes = taobao_onsale_product.parse_attrs if matchs?(taobao_onsale_product) || self.new_record?
      upgrade_taobao_skus(taobao_onsale_product.taobao_skus,taobao_products)
    end
    
    def upgrade_taobao_skus(taobao_onsale_skus,taobao_products)
      if taobao_onsale_skus.present?
        taobao_onsale_skus.each do |taobao_onsale_sku|
          taobao_product = taobao_products.find {|taobao_product| taobao_product.matchs?(taobao_onsale_sku)}
          #如果有从淘宝抓过来的记录,替换之
          taobao_onsale_skus_attributes = taobao_onsale_sku.marshal_dump.except(:created, :modified, :outer_id, :price)
          if taobao_product.present?
            taobao_onsale_sku.attributes = taobao_onsale_skus_attributes
          else
            #否则重新生成
            self.taobao_skus.build(taobao_onsale_skus_attributes)
          end
        end
      elsif taobao_skus.blank?
        #如果淘宝抓取过来的商品没有taobao_sku,且本地也没有taobao_skus记录 ,本地创建一个
        self.taobao_skus.build(taobao_product_id: self.id, num_iid: self.num_iid,:account_id => self.account_id) 
      end
    end
    
    def matchs?(taobao_onsale_sku)
      self.num_iid == taobao_onsale_sku.num_iid
    end
  end
end