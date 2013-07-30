require 'e_commerce/synchronization'
class TaobaoProductSync < ECommerce::Synchronization::Base
  identifier 'num_iid'
  set_variable :get_size, 100
  set_variable :page_no, 1
  set_variable :page_count, proc { |v|  total_results.zero? ? 1 : (total_results / get_size.to_f).ceil}

  def initialize(nick)
    @nick = nick
    @account = Account.find_by_key(nick)
    @trade_source = @account.trade_source
    super
  end

  def response
    @response = TaobaoQuery.get({method: 'taobao.items.onsale.get', fields: 'num_iid,num,detail_url,title,sku.properties_name,sku.properties,sku.quantity, sku.sku_id, outer_id, product_id, pic_url,cid,price,cat_name', nick: @nick, page_size: @get_size, page_no: page_no}, @trade_source.id)
    @response["items_onsale_get_response"]["items"]["item"]
  end

  def parsing
    super
    (@page_no += 1) && super while page_no < page_count
  end

  def total_results
    @total_results ||= @response["items_onsale_get_response"]["total_results"]
  end
end