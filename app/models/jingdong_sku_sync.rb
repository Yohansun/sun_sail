#encoding: utf-8

# j = JingdongProductSync.new
# j.parsing
# d = JingdongSkuSync.new(j.ware_ids)
# d.parsing

class JingdongSkuSync < ECommerce::Synchronization::Base
  identifier 'ware_id'
  alias_columns :attributes => "attribute_s"
  
  def initialize(ware_ids)
    @ware_ids = Array.wrap(ware_ids)
    @split_ids = []
  end

  def response
    @response = JingdongFu.get({method: '360buy.ware.skus.get', ware_ids: @split_ids.join(',')})
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
