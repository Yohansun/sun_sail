class JingdongProductSync < ECommerce::Synchronization::Base
  identifier 'ware_id'
  set_variable :get_size, 100
  set_variable :page_no, 1
  set_variable :page_count, proc { |v|  total_results.zero? ? 1 : (total_results / get_size.to_f).ceil}
  set_variable :api,'360buy.ware.listing.get'
  alias_columns :attributes => "attribute_s"
  attr_reader :account_id

  def initialize(trade_source_id)
    @trade_source = TradeSource.find(trade_source_id)
    @default_attributes = {account_id: @trade_source.account_id,genre: 0,trade_source_id: trade_source_id,shop_name: @trade_source.name}
    @api_parameters = @trade_source.jingdong_query_conditions
    super
  end

  def response
    params = {method: api, page_size: get_size, page: page_no}
    @response = JingdongQuery.get(params,@api_parameters)
    datas = {api_results: @response,api_parameters: params,:trade_source => @trade_source,:result => []}
    handle_exception(datas) do
      @response["ware_listing_get_response"]["ware_infos"]
    end
  end

  def total_results
    @total_results ||= @response["ware_listing_get_response"]["total"] rescue 0
  end

  def parsing
    @ware_ids ||= []
    (@ware_ids += super.collect{|u| u["ware_id"]}) && (@page_no += 1) while page_no <= page_count
  end

  def ware_ids
    @ware_ids ||= []
  end
end
