<% if namespaced? -%>
require_dependency "<%= namespaced_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= class_name %>Sync < ECommerce::Synchronization::Base
  # identifier 'tid'
  # def initialize(nick)
  # ...  
  # end
  # 
  # def response
  #   @response = TaobaoQuery.get({method: 'taobao.items.onsale.get', fields: 'num_iid,num,detail_url,title,sku.properties_name,sku.properties,sku.quantity, sku.sku_id, outer_id, product_id, pic_url,cid,price,cat_name', nick: nick, page_size: GET_SIZE, page_no: page_no}, trade_source_id)
  #   @response["items_onsale_get_response"]["items"]["item"] rescue $!
  # end

end
<% end -%>
