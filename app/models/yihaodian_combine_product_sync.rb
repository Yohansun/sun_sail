#encoding: utf-8
#一号店套餐产品
class YihaodianCombineProductSync < ECommerce::Synchronization::Base
  set_klass "YihaodianProduct"
  identifier 'product_id'
  set_variable :get_size, 100
  set_variable :page_no, 1
  set_variable :page_count, proc { |v|  total_results.zero? ? 1 : (total_results / get_size.to_f).ceil}

  def initialize(key)
    @account = Account.find_by_key key
    @account_id = @account.id
    @default_attributes = {account_id: @account_id,genre: 1}
    @query_condition = @account.yihaodian_query_conditions
    super
  end

  def response
    @response = YihaodianQuery.post({method: "yhd.combine.products.search",canSale: 1, pageRows: get_size, curPage: page_no},@query_condition)
    @response["response"]["comProductList"]["comProduct"].each { |hash| hash.underscore_key! } rescue []
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
