#encoding: utf-8

# j = JingdongProductSync.new(:vanward)
# j.parsing
# d = JingdongSkuSync.new({ware_ids: j.ware_ids,account_id: j.account_id})
# d.parsing

class JingdongSkuSync < ECommerce::Synchronization::Base
  identifier 'ware_id'
  alias_columns :attributes => "attribute_s"
  set_variable :api,'360buy.ware.skus.get'

  def initialize(options={})
    options.symbolize_keys!
    raise "The *trade_source_id* option can't be blank" if options[:trade_source_id].blank?
    @ware_ids = options.delete(:ware_ids)
    @trade_source = TradeSource.find(options[:trade_source_id])
    @default_attributes = {account_id: @trade_source.account_id,genre: 0,trade_source_id: trade_source_id,shop_name: @trade_source.name}.merge(options)
    @query_condition = @trade_source.jingdong_query_conditions
    @split_ids = []
  end

  def response
    return [] if @split_ids.blank?
    params = {method: api, ware_ids: @split_ids.join(',')}
    @response = JingdongQuery.get(params,@api_parameters)
    datas = {api_results: @response,api_parameters: params,:trade_source => @trade_source,:result => []}
    handle_exception(datas) do
      @response["ware_skus_get_response"]["skus"]
    end
  end

  def total_results
    @total_results ||= @ware_ids
  end
  
  def parsing
    @changed ||= []
    @latest ||= []

    @ware_ids.each_slice(10) do |ware_ids|
      @split_ids = ware_ids
      super
    end
  end
end
