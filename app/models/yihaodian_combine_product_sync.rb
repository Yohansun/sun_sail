#encoding: utf-8
#一号店套餐产品
class YihaodianCombineProductSync < ECommerce::Synchronization::Base
  set_klass "YihaodianProduct"
  identifier 'product_id'
  set_variable :get_size, 100
  set_variable :api, "yhd.combine.products.search"
  set_variable :page_no, 1
  set_variable :page_count, proc { |v|  total_results.zero? ? 1 : (total_results / get_size.to_f).ceil}

  def initialize(key)
    @account = Account.find_by_key key
    @default_attributes = {account_id: @account.id,genre: 1}
    @query_condition = @account.yihaodian_query_conditions
    super
  end

  def response
    params = {method: api,canSale: 1, pageRows: get_size, curPage: page_no}
    @response = YihaodianQuery.post(params,@query_condition)
    datas = {api_results: @response,api_parameters: params,:account => @account,:result => []}
    handle_exception(datas) do
      except_error = @response["response"]["errInfoList"]["errDetailInfo"].all? {|u| u["errorCode"] == 'yhd.combine.products.search.prod_not_found'} rescue false
      return [] if except_error
      @response["response"]["comProductList"]["comProduct"].each { |hash| hash.underscore_key! }
    end
  end

  def total_results
    @total_results ||= @response["response"]["totalCount"]
  end

  def parsing
    @combine_product_ids ||= []
    (@combine_product_ids += super.collect{|u| u["product_id"]}) && (@page_no += 1) while page_no <= page_count
  end

  def product_ids
    @combine_product_ids
  end
end
