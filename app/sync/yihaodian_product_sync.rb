#encoding: utf-8
class YihaodianProductSync < BaseSync
  PAGE_SIZE = 100
  group :combine_products do
    options do |option|
      option[:message]    = "一号店套餐商品"
      option[:batch]      = true
      option[:total_page] = Proc.new { |response| (response["response"]["totalCount"].to_i / PAGE_SIZE.to_f).ceil }
      option[:items]      = Proc.new { |response| response["response"]["comProductList"]["comProduct"] }
      option[:attributes] = {genre: 1}
    end

    query     {|options| {method: "yhd.combine.products.search",canSale: 1, pageRows: PAGE_SIZE, curPage: options[:current_page] } }
    response  {|query,trade_source| YihaodianQuery.post(query,trade_source.yihaodian_query_conditions)}

    parser do |struct|
      struct.merge!(options[:attributes])
      standard_struct(struct,YihaodianProduct)
    end
  end

  group :general_products do
    options do |option|
      option[:message]    = "一号店普通商品"
      option[:batch]      = true
      option[:total_page] = Proc.new { |response| (response["response"]["totalCount"] / PAGE_SIZE.to_f).ceil }
      option[:items]      = Proc.new { |response| response["response"]["productList"]["product"] }
      option[:attributes] = {genre: 0}
    end

    query     {|options| {method: "yhd.general.products.search",verifyFlg: 2, pageRows: PAGE_SIZE, curPage: options[:current_page] } }
    response  {|query,trade_source| YihaodianQuery.post(query,trade_source.yihaodian_query_conditions)}

    parser do |struct|
      struct.merge!(options[:attributes])
      standard_struct(struct,YihaodianProduct)
    end
  end

  group :serial_products do
    options do |option|
      option[:message]    = "一号店系列商品"
      option[:batch]      = true
      option[:total_page] = Proc.new { |response| (response["response"]["totalCount"] / PAGE_SIZE.to_f).ceil }
      option[:items]      = Proc.new { |response| response["response"]["serialProductList"]["serialProduct"] }
      option[:attributes] = {genre: 2}
    end

    query     {|options| {method: "yhd.serial.products.search",verifyFlg: 2, pageRows: PAGE_SIZE, curPage: options[:current_page] } }
    response  {|query,trade_source| YihaodianQuery.post(query,trade_source.yihaodian_query_conditions)}

    parser do |struct|
      struct.merge!(options[:attributes])
      standard_struct(struct,YihaodianProduct)
    end
  end

  def _products(page=nil)
    @_products = nil if @_products.blank?
    @_products ||= ActiveRecord::Base.connection.select_values(products_scope.select(:product_id))
    Kaminari.paginate_array(@_products, {offset: page || options[:current_page] - 1,limit: 1})
  end

  group :serial_skus do
    options do |option|
      option[:message]    = "一号店系列子品"
      option[:batch]      = true
      option[:total_page] = Proc.new { |response| _products.total_pages }
      option[:items]      = Proc.new { |response| response["response"]["serialChildProdList"]["serialChildProd"] }
      option[:attributes] = {genre: 2}
    end

    query     {|options| {method: "yhd.serial.product.get",productId: @product_id = _products.shift} }
    response  {|query,trade_source| YihaodianQuery.post(query,trade_source.yihaodian_query_conditions)}

    parser do |struct|
      standard_struct(struct,YihaodianSku)
    end
  end

  # def _combine_products(page=nil)
  #   @combine_products ||= ActiveRecord::Base.connection.select_values(products_scope,:product_id)
  #   Kaminari.paginate_array(@combine_products, {offset: page || options[:current_page],limit: 1})
  # end

  group :combine_skus do
    options do |option|
      option[:message]    = "一号店套餐子品"
      option[:batch]      = true
      option[:total_page] = Proc.new { |response| _products.total_pages }
      option[:items]      = Proc.new { |response| response["response"]["comChildProdList"]["comChildProd"] }
      option[:attributes] = {genre: 1}
    end

    query     {|options| {method: "yhd.combine.product.get",productId: @product_id = _products.shift } }
    response  {|query,trade_source| YihaodianQuery.post(query,trade_source.yihaodian_query_conditions)}

    parser do |struct|
      standard_struct(struct,YihaodianSku)
    end
  end

  def processes(gp,items)
    ActiveRecord::Base.transaction do
      send(:"processes_#{gp}",items)
    end
  end
  
  [:combine_products,:general_products,:serial_products].each do |method_id|
    define_method(:"processes_#{method_id}") do |items|
      items.each do |item|
        create_or_update_product(item,find_product(item,items))
      end
    end
  end
  
  [:serial_skus,:combine_skus].each do |method_id|
    define_method(:"processes_#{method_id}") do |items|
      items.each do |item|
        create_or_update_sku(item,find_sku(item))
      end
    end
  end

  def products_scope
    YihaodianProduct.where(default_attributes).where(options[:attributes])
  end

  def skus_scope
    YihaodianSku.where(default_attributes).where(parent_product_id: @product_id)
  end

  def default_attributes
    { account_id: trade_source.account_id,trade_source_id: trade_source.id,shop_name: trade_source.name }
  end

  def tmp_products(items)
    products_scope.where(product_id: items.collect {|item| item["product_id"]}).to_a
  end

  def tmp_skus
    skus_scope.to_a
  end

  private
  def create_or_update_product(item,product)
    record = product.nil? ? products_scope.create(item) : product.update_attributes(item) && product
    log(product.nil? ? "Create" : "Update",item,record.previous_changes)
  end

  def create_or_update_sku(item,sku)
    record = sku.nil? ? skus_scope.create(item) : sku.update_attributes(item) && sku
    log(sku.nil? ? "Create" : "Update",item,record.previous_changes)
  end

  def find_product(item,items)
    tmp_products(items).find {|product| product["product_id"].to_s == item["product_id"].to_s}
  end

  def find_sku(item)
    tmp_skus.find {|sku| sku["product_id"].to_s == item["product_id"].to_s}
  end

  def standard_struct(item,klass)
    item.underscore_key!
    columns = klass.columns_hash.except("id").keys
    item.merge!(default_attributes)
    item.stringify_keys!
    item.slice!(*columns)
  end

  def log(action,struct,changes)
    Rails.logger.info "[#{Time.now}] #{action} by #{self.class.name}##{group_name} as \n  Parameters: #{struct.inspect} \n  Changes: #{changes.inspect  if action == 'Update'} \n\n"
  end
end