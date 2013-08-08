class YihaodianSkuSync < ECommerce::Synchronization::Base
  identifier 'product_id'
  set_variable :get_size, 100
  set_variable :page_no, 1
  set_variable :page_count, proc { |v|  total_results.zero? ? 1 : (total_results / get_size.to_f).ceil}
  attr_reader :account_id

  def initialize(key)
    @account = Account.find_by_key key
    @account_id = @account.id
    @default_attributes = {account_id: @account_id}
    super
  end

  def response
    # query_conditions = @account.jingdong_query_conditions
    # @response = JingdongQuery.get({method: 'yhd.general.products.search', page_size: get_size, page: page_no},query_conditions)
    # @response["response"]["productList"] rescue []
  end

  def total_results
    @total_results ||= @response["ware_listing_get_response"]["total"]
  end

  def parsing
    @product_ids ||= []
    (@product_ids += super.collect{|u| u["productId"]}) && (@page_no += 1) while page_no <= page_count
  end

  def product_ids
    @product_ids
  end
end
