#encoding: utf-8
#一号店系列子品
class YihaodianSerialSkuSync < ECommerce::Synchronization::Base
  set_klass "YihaodianSku"
  identifier 'parent_product_id'
  set_variable :api,"yhd.serial.product.get"
  
  def initialize(options={})
    options.symbolize_keys!
    raise "The *account_id* option can't be blank" if options[:account_id].blank?
    @product_ids = Array.wrap(options.delete(:product_ids) || [])
    @default_attributes = options
    @query_condition = Account.find(options[:account_id]).yihaodian_query_conditions
    super
  end

  
  def response
    return [] if @product_id.blank?
    params = {method: api, productId: @product_id,product_ids: @product_ids}
    @response = YihaodianQuery.post(params,@query_condition)
    datas = {api_results: @response,api_parameters: params,:account_id => @query_condition[:account_id],:result => []}
    handle_exception(datas) do
      @response["response"]["serialChildProdList"]["serialChildProd"].each { |hash| hash.delete("allWareHouseStocList") && hash.underscore_key!.merge!({"parent_product_id" => @product_id})}
    end
  end

  def parsing
    @product_ids.each do |product_id|
      @product_id = product_id
      super
    end
  end
end