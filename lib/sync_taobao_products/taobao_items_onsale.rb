#encoding: utf-8
class TaobaoItemsOnsale
  GET_SIZE = 100
  attr_accessor :nick,:responsed,:products,:total_results,:products,:account
  @remember = false

  def initialize(account)
    @page_no        = 1
    @account        = account
    @trade_source   = @account.taobao_source
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