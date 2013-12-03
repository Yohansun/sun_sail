require 'e_commerce/synchronization'
class TaobaoProductSync < ECommerce::Synchronization::Base
  identifier 'num_iid'
  set_variable :get_size, 100
  set_variable :page_no, 1
  set_variable :page_count, proc { |v|  total_results.zero? ? 1 : (total_results / get_size.to_f).ceil}
  alias_columns :title => "name"

  def initialize(trade_source_id)
    @trade_source = TradeSource.find(trade_source_id)
    @default_attributes = {account_id: @trade_source.account_id,shop_name: @trade_source.name,trade_source_id: trade_source_id}
    super
  end

  def response
    @response = TaobaoQuery.get({method: 'taobao.items.onsale.get', fields: 'num_iid,num,detail_url,title,sku.properties_name,sku.properties,sku.quantity, sku.sku_id, outer_id, product_id, pic_url,cid,price,cat_name', page_size: @get_size, page_no: page_no}, @trade_source.id)
    @response["items_onsale_get_response"]["items"]["item"].each do |item|
      item["taobao_skus_attributes"] = get_skus(item["num_iid"])
    end
  end

  def parsing
    super
    (@page_no += 1) && super while page_no < page_count
  end

  def total_results
    @total_results ||= @response["items_onsale_get_response"]["total_results"]
  end

  def get_skus(num_iid)
    default_sku_attibutes = @default_attributes
    skus = TaobaoQuery.get({method: 'taobao.item.get',  fields: 'sku', num_iid: num_iid}, @trade_source.id)
    skus_attributes = {}
    handle_exception(skus.merge(@default_attributes)) {
      skus['item_get_response']['item']['skus'] = {"sku" => [{num_iid: num_iid}]} if skus['item_get_response']['item'].blank?
      skus['item_get_response']['item']['skus']['sku'].each_with_index do |sku,index|
        sku.merge!(default_sku_attibutes)
        sku_dup = sku.dup.stringify_keys.slice(*TaobaoSku.columns_hash.keys)
        sku.clear
        taobao_sku_id  = TaobaoSku.includes(:taobao_product).where(taobao_products: {num_iid: num_iid},taobao_skus: {sku_id: sku_dup["sku_id"]}).first.try(:id)
        skus_attributes[index+1] = {"id" => taobao_sku_id}.reject{|k,v| v.nil?}.merge(sku_dup)
      end
    }
    skus_attributes
  end
end