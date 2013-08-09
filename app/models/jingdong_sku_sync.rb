#encoding: utf-8

# j = JingdongProductSync.new(:vanward)
# j.parsing
# d = JingdongSkuSync.new({ware_ids: j.ware_ids,account_id: j.account_id})
# d.parsing

class JingdongSkuSync < ECommerce::Synchronization::Base
  identifier 'ware_id'
  alias_columns :attributes => "attribute_s"
  
  def initialize(options={})
    options.symbolize_keys!
    raise "The *ware_ids* option can't be blank" if options[:ware_ids].blank?
    raise "The *account_id* option can't be blank" if options[:account_id].blank?
    @ware_ids = options.delete(:ware_ids)
    @default_attributes = options
    @query_condition = Account.find(options[:account_id]).jingdong_query_conditions
    @split_ids = []
  end

  def response
    @response = JingdongQuery.get({method: '360buy.ware.skus.get', ware_ids: @split_ids.join(',')},@query_condition)
    @response["ware_skus_get_response"]["skus"] rescue []
  end
  
  def total_results
    @total_results ||= @ware_ids
  end
  
  def parsing
    @ware_ids.each_slice(10) do |ware_ids|
      @split_ids = ware_ids
      super
    end
  end
end
