#encoding: utf-8
#一号店套餐子品
class YihaodianCombineSkuSync < ECommerce::Synchronization::Base
  set_klass "YihaodianSku"
  identifier 'product_id'
  
  def initialize(options={})
    options.symbolize_keys!
    raise "The *account_id* option can't be blank" if options[:account_id].blank?
    @product_ids = Array.wrap(options.delete(:product_ids) || [])
    @default_attributes = options
    @query_conditions = Account.find(options[:account_id]).yihaodian_query_conditions
    super
  end
  
  def response
    @response = YihaodianQuery.post({method: "yhd.combine.product.get", productId: @product_id},@query_condition)
    @response["response"]["comChildProdList"]["comChildProd"].each { |hash| hash.underscore_key! } rescue []
  end

  def parsing
    @product_ids.each do |product_id|
      @product_id = product_id
      super
    end
  end
end
