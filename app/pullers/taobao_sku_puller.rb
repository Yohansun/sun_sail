#encoding: utf-8
# TaobaoSkuPuller.new(trade_source_id).sync
class TaobaoSkuPuller < BaseSync
  def default_options
    super.merge(redis_key: "TaobaoSku-sku_id",error_message: "淘宝抓取SKU同步异常(#{trade_source.name})")
  end

  def sync
    each_page do |response|
      response["items_list_get_response"]["items"]["item"].each do |item|
        next if !item.is_a?(Hash)
        # 如果商品没有sku则创建一个
        item["skus"] = {"sku" => [{}] } if item["skus"].blank?
        item["skus"]["sku"].each {|sku| craete_or_update(sku.merge(num_iid: item["num_iid"])) }
      end
    end
  end

  def fetch_data
    TaobaoQuery.get(query.merge!(num_iids: products.map(&:num_iid).join(",")), trade_source.id)
  end

  def query
    @query ||= {method: 'taobao.items.list.get',  fields: 'num_iid,sku',page_no: 1}
  end

  def total_page
    Proc.new {|response| products.total_pages}
  end

  def products
    TaobaoProduct.where(trade_source_id: trade_source.id).page(query[:page_no] ||= 1).per(20)
  end

  def craete_or_update(struct)
    parse_response(struct)
    sku = if exists?(struct["sku_id"])
      action = "Update"
      sku = TaobaoSku.where(default_attributes).where(sku_id: struct["sku_id"]).first
      sku.update_attributes!(struct) && sku
    else
      $redis.sadd(options[:redis_key],struct["sku_id"])
      action = "Create"
      sku = TaobaoSku.new(struct)
      sku.save! && sku
    end

    Rails.logger.info "[#{Time.now}] #{action} by #{self.class.name}##{__method__} as \n  Parameters: #{struct.inspect} \n  Changes: #{sku.previous_changes.inspect  if action == 'Update'} \n\n"
  end

  def exists?(num_iid)
    if $redis.smembers(options[:redis_key]).blank?
      sku_ids = TaobaoSku.where(default_attributes).select("distinct sku_id").map(&:sku_id).reject {|sku_id| sku_id.blank?}
      $redis.sadd(options[:redis_key],sku_ids)
    end

    $redis.sismember(options[:redis_key],num_iid) || TaobaoSku.where(default_attributes).where(sku_id: struct["sku_id"]).first && $redis.sadd(options[:redis_key],num_iid)
  end

  def parse_response(struct)
    columns = TaobaoSku.columns_hash.keys
    struct.merge!(default_attributes)
    struct.stringify_keys!
    struct.slice!(*columns)
  end

  def default_attributes
    {account_id: trade_source.account_id,trade_source_id: trade_source.id,shop_name: trade_source.name}
  end
end