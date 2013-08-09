#encoding: utf-8
#一号店系列产品
class YihaodianSerialProductSync < ECommerce::Synchronization::Base
  set_klass "YihaodianProduct"
  identifier 'product_id'
  set_variable :get_size, 100
  set_variable :page_no, 1
  set_variable :page_count, proc { |v|  total_results.zero? ? 1 : (total_results / get_size.to_f).ceil}
  
  def initialize(key)
    @account = Account.find_by_key key
    @account_id = @account.id
    @default_attributes = {account_id: @account_id,genre: 2}
    @query_condition = @account.yihaodian_query_conditions
    super
  end
  
  def response
    YihaodianQuery.load 'config/yihaodian.yml'
    @response = YihaodianQuery.post({method: "yhd.serial.products.search",verifyFlg: 2, pageRows: get_size, curPage: page_no},@query_condition)
    @response["response"]["serialProductList"]["serialProduct"].each { |hash| hash.underscore_key! } rescue []
  end
  
  def total_results
    @total_results ||= @response["response"]["totalCount"]
  end

  def parsing
    @serial_product_ids ||= []
    (@serial_product_ids += super.collect{|u| u["product_id"]}) && (@page_no += 1) while page_no <= page_count
  end

  def product_ids
    @serial_product_ids
  end
end
