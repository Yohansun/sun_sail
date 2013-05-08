#encoding: utf-8
class ChangeStat < ::TaobaoProduct
  TaobaoSku.class_eval { attr_accessor :onsale_product_sku }
  
  #更新当前记录
  def upgrade(taobao_onsale_product)
    self.attributes = taobao_onsale_product.parse_attrs
    upgrade_taobao_skus(taobao_onsale_product)
  end
  
  #更新taobao_products
  def upgrade_taobao_skus(taobao_onsale_product)
    exists_onsale_skus,not_exists_onsale_skus = taobao_onsale_product.partition_skus(taobao_skus.map(&:attributes))
    match_skus,not_match_skus = partition_skus(exists_onsale_skus)
    if exists_onsale_skus.present?
      update_taobao_skus(match_skus)                                if match_skus.present?
      remove_taobao_skus(not_match_skus)                            if not_match_skus.present?
    end
    add_taobao_skus(not_exists_onsale_skus)                       if not_exists_onsale_skus.present?
    
    #如果淘宝抓取过来的商品没有taobao_sku,且本地也没有taobao_skus记录 ,本地创建一个
    self.taobao_skus.build(taobao_product_id: self.id, num_iid: self.num_iid,:account_id => self.account_id)  if taobao_skus.blank?
  end
  
  # => 匹配的taobao_skus, 不匹配的taobao_skus = partition_skus(taobao_onsale_skus)
  def partition_skus(taobao_onsale_skus)
    self.taobao_skus.partition do |taobao_sku|
      taobao_onsale_skus.any? do |taobao_onsale_sku| 
        if match_sku?(taobao_sku,taobao_onsale_sku)
          taobao_sku.onsale_product_sku = taobao_onsale_sku
          true
        end
      end
    end
  end
  
  
  def update_taobao_skus(taobao_skus)
    taobao_skus.each do |taobao_sku|
      onsale_taobao_skus = taobao_sku.onsale_product_sku
      taobao_onsale_skus_attributes = onsale_taobao_skus.marshal_dump.except(:created, :modified, :outer_id, :price)
      taobao_sku.attributes = taobao_onsale_skus_attributes
    end
  end
  
  def remove_taobao_skus(taobao_skus)
    taobao_skus.each do |taobao_sku|
      taobao_sku.taobao_product_id = nil
    end
  end
  
  def add_taobao_skus(not_exists_onsale_skus)
    not_exists_onsale_skus.each do |news_taobao_sku|
      taobao_onsale_skus_attributes = news_taobao_sku.marshal_dump.except(:created, :modified, :outer_id, :price)
      self.taobao_skus.build(taobao_onsale_skus_attributes) 
    end
  end
  
  def match_sku?(current_sku,taobao_sku)
    current_sku.sku_id == taobao_sku.sku_id ||
    current_sku.sku_id.blank? && current_sku.num_iid == taobao_sku.num_iid
  end
end