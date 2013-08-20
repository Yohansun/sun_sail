#encoding: utf-8
#一号店普通产品
class YihaodianGeneralProductSync < ECommerce::Synchronization::Base
  set_klass "YihaodianProduct"
  identifier 'product_id'
  set_variable :api, "yhd.general.products.search"
  set_variable :get_size, 100
  set_variable :page_no, 1
  set_variable :page_count, proc { |v|  total_results.zero? ? 1 : (total_results / get_size.to_f).ceil}

  def initialize(key)
    @account = Account.find_by_key key
    @default_attributes = {account_id: @account.id,genre: 0}
    @query_condition = @account.yihaodian_query_conditions
    super
  end

  def response
    params = {method: api,verifyFlg: 2, pageRows: get_size, curPage: page_no}
    @response = YihaodianQuery.post(params,@query_condition)
    datas = {api_results: @response,api_parameters: params,:account => @account,:result => []}
    handle_exception(datas) do
      @response["response"]["productList"]["product"].each {|hash| hash.underscore_key!}
    end
  end

  def total_results
    @total_results ||= @response["response"]["totalCount"]
  end

  def parsing
    @general_product_ids ||= []
    (@general_product_ids += super.collect{|u| u["product_id"]}) && (@page_no += 1) while page_no <= page_count
  end
end
