#encoding: utf-8
#一号店套餐子品
class YihaodianCombineSkuSync < ECommerce::Synchronization::Base
  set_klass "YihaodianSku"
  identifier 'product_id'
  set_variable :api, "yhd.combine.product.get"
  
  def initialize(options={})
    options.symbolize_keys!
    raise "The *account_id* option can't be blank" if options[:account_id].blank?
    @account = Account.find(options[:account_id])
    @product_ids = Array.wrap(options.delete(:product_ids) || [])
    @default_attributes = options
    @query_conditions = @account.yihaodian_query_conditions
    super
  end
  
  def response
    return [] if @product_id.blank?
    params = {method: api , productId: @product_id,product_ids: @product_ids}
    @response = YihaodianQuery.post(params,@query_condition)
    datas = {api_results: @response,api_parameters: params,:account => @account}
    handle_exception(datas) do
      @response["response"]["comChildProdList"]["comChildProd"].each { |hash| hash.underscore_key! }
    end
  end

  def parsing
    @product_ids.each do |product_id|
      @product_id = product_id
      super
    end
  end
end
