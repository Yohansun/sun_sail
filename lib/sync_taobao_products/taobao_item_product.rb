#encoding: utf-8
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
    prefix_skus     = {:account_id => @account_id,:num_iid => num_iid }
    @taobao_skus  ||= get_skus.collect {|taobao_sku| OpenStruct.new(taobao_sku.merge!(prefix_skus))}
  end
  
  # exists_skus,not_exists_skus = partition_skus(attributes)
  def partition_skus(taobao_skus_attributes)
    taobao_skus.partition do |taobao_sku|
      taobao_skus_attributes.any? do |x|
        taobao_sku.sku_id.present? && taobao_sku.sku_id.to_i == x["sku_id"].to_i ||
        x["sku_id"].blank? && taobao_sku.num_iid.to_i == x["num_iid"].to_i
      end
    end
  end
  
  def insert!
    new_product = CompareProduct::ChangeStat.new
    new_product.upgrade(self)
    new_product.save!
  end
  
  private
  def struct_product
    OpenStruct.new(@attrs)
  end
end