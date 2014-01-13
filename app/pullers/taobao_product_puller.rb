#encoding: utf-8
# TaobaoProductPuller.new(trade_source_id).sync
class TaobaoProductPuller < BaseSync
  FIELDS = 'num_iid,num,detail_url,title,sku.properties_name,sku.properties,sku.quantity, sku.sku_id, outer_id, product_id, pic_url,cid,price,cat_name'
  PAGE_SIZE = 100

  def default_options
    {end_time: Time.now,redis_key: "TaobaoProduct-num_iids",error_message: "淘宝抓取商品同步异常(#{trade_source.name})"}
  end

  def sync
    each_page do |response|
      response["items_onsale_get_response"]["items"]["item"].each {|item| create_or_update(item)}
    end
  end

  def create_or_update(struct)
    action = nil
    parse_response(struct)
    num_iid = struct["num_iid"]
    product = if exists?(num_iid)
      product = TaobaoProduct.where(default_attributes).where(num_iid: num_iid).first
      action = "Updata"
      product.update_attributes!(struct) && product
    else
      $redis.sadd(options[:redis_key],num_iid)
      action = "Create"
      product = TaobaoProduct.new(struct)
      product.save! && product
    end

    Rails.logger.info "[#{Time.now}] #{action} by #{self.class.name}##{__method__} as \n  Parameters: #{struct.inspect} \n  Changes: #{product.previous_changes.inspect  if action == 'Update'} \n\n"
  end

  def exists?(num_iid)
    if $redis.smembers(options[:redis_key]).blank?
      num_iids = TaobaoProduct.where(default_attributes).select("distinct num_iid").map(&:num_iid).reject { |num_iid| num_iid.blank? }
      $redis.sadd(options[:redis_key], num_iids)
    end

    $redis.sismember(options[:redis_key],num_iid.to_i) ||
    TaobaoProduct.where(default_attributes).where(num_iid: num_iid).exists? && $redis.sadd(options[:redis_key],num_iid)
  end

  def fetch_data
    TaobaoQuery.get(query,trade_source.id)
  end

  def default_attributes
    {account_id: trade_source.account_id,trade_source_id: trade_source.id,shop_name: trade_source.name}
  end

  def parse_response(struct)
    columns = TaobaoProduct.columns_hash.keys - ['id']
    struct["name"] = struct.delete("title")
    struct.slice!(*columns)
  end

  def query
    @query ||= {method: 'taobao.items.onsale.get',fields: FIELDS,page_size: PAGE_SIZE,page_no: 1}
  end

  def total_page
    Proc.new { |response| (response["items_onsale_get_response"]["total_results"] / query[:page_size].to_f).ceil }
  end
end
