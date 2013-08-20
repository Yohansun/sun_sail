class JingdongProductSync < ECommerce::Synchronization::Base
  identifier 'ware_id'
  set_variable :get_size, 100
  set_variable :page_no, 1
  set_variable :page_count, proc { |v|  total_results.zero? ? 1 : (total_results / get_size.to_f).ceil}
  alias_columns :attributes => "attribute_s"
  attr_reader :account_id

  def initialize(key)
    account = Account.find_by_key key
    @default_attributes = {account_id: @account.id}
    @api_parameters = account.jingdong_query_conditions
    super
  end

  def response
    @response = JingdongQuery.get({method: '360buy.ware.listing.get', page_size: get_size, page: page_no},@api_parameters)
    @response.key?("error_response") && raise(@response["error_response"].inspect)
    @response["ware_listing_get_response"]["ware_infos"]
  end

  def total_results
    @total_results ||= @response["ware_listing_get_response"]["total"]
  end

  def parsing
    @ware_ids ||= []
    (@ware_ids += super.collect{|u| u["ware_id"]}) && (@page_no += 1) while page_no <= page_count
  end

  def ware_ids
    @ware_ids
  end
end
