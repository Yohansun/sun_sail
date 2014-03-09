#encoding: utf-8
class TaobaoProductSync < BaseSync
  FIELDS = 'num_iid,num,detail_url,title,sku.properties_name,sku.properties,sku.quantity, sku.sku_id, outer_id, product_id, pic_url,cid,price,cat_name'
  PAGE_SIZE = 100

  group :products do
    query     { |options| {method: 'taobao.items.onsale.get',fields: FIELDS,page_size: PAGE_SIZE,page_no: options[:current_page] } }
    response  { |query,trade_source| TaobaoQuery.get(query,trade_source.id)}
    options do |option|
      option[:message]    = "淘宝商品"
      option[:batch]      = true
      option[:total_page] = Proc.new { |response,query| (response["items_onsale_get_response"]["total_results"] / query[:page_size].to_f).ceil }
      option[:items]      = Proc.new {|response| response["items_onsale_get_response"]["items"]["item"] }
    end

    parser do |struct|
      columns = TaobaoProduct.columns_hash.keys - ['id']
      struct.merge!(default_attributes)
      struct.stringify_keys!
      struct["cid"] = struct["cid"].to_s
      struct["name"] = struct.delete("title")
      struct.slice!(*columns)
    end
  end

  # 用来抓取sku
  def taobao_products(page=nil)
    TaobaoProduct.where(trade_source_id: trade_source.id).page(page || query[:page_no]).per(20) 
  end

  # 淘宝获取SKU列表是根据商品的num_iid来获取的,  每次只能取20个num_iid去查找.
  # 所以通过kaminari来统计总的页数,然后去遍历每一页去找num_iids来发送一个request.

  group :skus do
    query     do |options|
      # page_no主要给 products做分页
      page_no = options[:current_page]
      {method: 'taobao.items.list.get',  fields: 'num_iid,property_alias,sku',page_no: page_no,num_iids: taobao_products(page_no).map(&:num_iid).join(",")}
    end

    response  do |query,trade_source|
      TaobaoQuery.get(query, trade_source.id)
    end

    options do |option|
      option[:message]      = "淘宝SKU"
      option[:batch]        = true
      options[:total_page]  = Proc.new { |response,query| taobao_products.total_pages }
      # 返回的商品可能没有sku, 可能会有多个sku.
      # option的items是用来遍历去创建或更新的,  所以同意处理了一下商品的sku
      option[:items]  = Proc.new {|response|
        items = response["items_list_get_response"]["items"]["item"].each do |item|
          if item["skus"].blank?
            item["skus"] = {"sku" => [{num_iid: item["num_iid"]}] }
          else
            item["skus"]["sku"].each {|sku| sku["num_iid"] = item["num_iid"]; sku["property_alias"] = item["property_alias"]}
          end
        end
        items.collect {|item| item["skus"]["sku"]}.flatten
      }
    end

    parser do |struct|
      columns = TaobaoSku.columns_hash.keys
      struct.merge!(default_attributes)
      struct.stringify_keys!
      struct.slice!(*columns)
    end
  end

  def processes(gp,items)
    ActiveRecord::Base.transaction do
      send(:"processes_#{gp}",items)
    end
  end

  def processes_products(items)
    num_iids = items.collect {|item| item["num_iid"]}.compact
    # 减少查询次数
    taobao_products = TaobaoProduct.where(default_attributes).where(num_iid: num_iids).to_a
    items.each do |item|
      create_or_update_with_product(item,find_product(taobao_products,item))
    end
  end

  def processes_skus(items)
    sku_ids   = items.collect {|item| item["sku_id"] }.compact
    num_iids  = items.select {|item| item["sku_id"].blank? }.collect {|item| item["num_iid"] }.compact
    # 减少查询次数
    taobao_skus = TaobaoSku.where(default_attributes).where("sku_id in (?) or num_iid in (?)",sku_ids,num_iids).to_a
    items.each do |item|
      create_or_update_with_sku(item, find_sku(taobao_skus,item))
    end
  end

  def create_or_update_with_product(struct,product)
    action = nil
    product = if product.present?
      action = "Updata [TaobaoProduct]"
      product.update_attributes!(struct) && product
    else
      action = "Create [TaobaoProduct]"
      product = TaobaoProduct.new(struct)
      product.save! && product
    end

    log(action,__method__,struct,product.previous_changes)
  end

  # 淘宝商品可能没有SKU, 没有一个固定的值找出SKU, 所以通过sku_id,outer_id,num_iid去找
  def create_or_update_with_sku(struct,sku)
    sku = if sku.present?
      action = "Update [TaobaoSku]"
      sku.update_attributes!(struct) && sku
    else
      action = "Create [TaobaoSku]"
      sku = TaobaoSku.new(struct)
      sku.save! && sku
    end

    log(action,__method__,struct,sku.previous_changes)
  end

  private

  def find_product(taobao_products,item)
    taobao_products.find {|product| product.num_iid.to_s == item["num_iid"].to_s}
  end

  def find_sku(taobao_skus,item)
    if item["sku_id"].present?
      taobao_skus.find {|sku| sku.sku_id.to_s == item["sku_id"].to_s}
    else
      taobao_skus.find {|sku| sku.num_iid.to_s == item["num_iid"].to_s}
    end
  end

  def default_attributes
    {account_id: trade_source.account_id,trade_source_id: trade_source.id,shop_name: trade_source.name}
  end

  def log(action,method_id,struct,changes)
    Rails.logger.info "[#{Time.now}] #{action} by #{self.class.name}##{method_id} as \n  Parameters: #{struct.inspect} \n  Changes: #{changes.inspect  if action == 'Update'} \n\n"
  end
end
