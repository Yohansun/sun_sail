#encoding: utf-8
class JingdongProductSync < BaseSync
  PAGE_SIZE = 100
  group :products do

    options do |option|
      option[:message]    = "京东商品"
      option[:batch]      = true
      option[:total_page] = Proc.new {|response| (response["ware_listing_get_response"]["total"] / PAGE_SIZE.to_f).ceil }
      option[:items]      = Proc.new {|response| response["ware_listing_get_response"]["ware_infos"] }
    end

    query     {|options| {method: '360buy.ware.listing.get', page_size: PAGE_SIZE, page: options[:current_page]} }
    response  {|query,trade_source| JingdongQuery.get(query,trade_source.jingdong_query_conditions) }

    parser do |struct|
      struct.merge!(default_attributes)
      struct["attribute_s"] = struct.delete("attributes")
      struct.stringify_keys!
      columns = JingdongProduct.columns_hash.keys.except("id")
      struct.slice!(*columns)
    end
  end

  def jingdong_products(page=nil)
    JingdongProduct.where(default_attributes).page(page || options[:current_page]).per(10)
  end

  group :skus do
    options do |option|
      option[:message]    = "京东SKU"
      option[:batch]      = true
      option[:total_page] = Proc.new {|response| jingdong_products.total_pages }
      option[:items]      = Proc.new {|response| response["ware_skus_get_response"]["skus"] }
    end

    query     {|options| {method: '360buy.ware.skus.get', ware_ids: jingdong_products(options[:current_page]).map(&:ware_id).join(',')} }

    response  {|query,trade_source| JingdongQuery.get(query,trade_source.jingdong_query_conditions)}

    parser do |struct|
      struct.merge!(default_attributes)
      struct["attribute_s"] = struct.delete("attributes")
      struct.stringify_keys!
      columns = JingdongSku.columns_hash.keys.except("id")
      struct.slice!(*columns)
    end
  end

  def processes(gp,items)
    ActiveRecord::Base.transaction do
      send(:"processes_#{gp}",items)
    end
  end

  def processes_products(items)
    products = JingdongProduct.where(default_attributes).where(ware_id: items.collect {|item| item["ware_id"]}).to_a
    items.each {|item| create_or_update_product(item,find_product(products,item)) }
  end

  def processes_skus(items)
    skus = JingdongSku.where(default_attributes).where(items.collect {|item| item["ware_id"]}).to_s
    items.each {|item| create_or_update_sku(item,find_sku(skus,item))}
  end

  def create_or_update_product(item,product)
    product = product.nil? ? JingdongProduct.create(item) : product.update_attributes(item)
    log(sku.nil? ? 'Create' : 'Update',__method__,item,product.previous_changes)
  end

  def create_or_update_sku(item,sku)
    sku = sku.nil? ? JingdongSku.create(item) : sku.update_attributes(item)
    log(sku.nil? ? 'Create' : 'Update',__method__,item,sku.previous_changes)
  end

  def find_product(products,item)
    products.find { |product| product.ware_id.to_s == item["ware_id"].to_s }
  end

  def find_sku(skus,item)
    skus.find { |product| sku.sku_id.to_s == item["sku_id"].to_s }
  end

  def default_attributes
    { account_id: trade_source.account_id, trade_source_id: trade_source.id,shop_name: trade_source.name}
  end

  def log(action,method_id,struct,changes)
    Rails.logger.info "[#{Time.now}] #{action} by #{self.class.name}##{method_id} as \n  Parameters: #{struct.inspect} \n  Changes: #{changes.inspect  if action == 'Update'} \n\n"
  end
end