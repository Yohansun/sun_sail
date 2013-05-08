#encoding: utf-8
#获取淘宝所有在线商品
require 'sync_taobao_products/taobao_items_onsale'
require 'sync_taobao_products/taobao_item_product'
require 'sync_taobao_products/change_stat'
#   对比本地商品有无更新
#   有商品变更则创建变更记录
#   本地无商品则创建
class CompareProduct
  attr_accessor :account,:num_iids,:onsale,:changes
  def initialize(account)
    @account      = account
    @onsale       = TaobaoItemsOnsale.new(account)
    @products     = @onsale.products
    @num_iids     = @products.map(&:num_iid)
    @changes    ||= changes_products
  end
  
  def have_exists_num_ids
    exists_taobao_products.pluck(:num_iid)
  end
  
  def not_exists_num_ids
    num_iids - have_exists_num_ids
  end
  
  def have_exists
    @have_exists ||= @products.select { |v| have_exists_num_ids.include?(v.num_iid) }
  end
  
  def not_exists
    @not_exists ||= @products.select {|v| not_exists_num_ids.include?(v.num_iid)}
  end
  
  def exists_taobao_products
    @exists_taobao_products ||= ChangeStat.where(:num_iid => @num_iids,:account_id => @account.id).includes(:taobao_skus)
  end
  
  def changes_products
    have_exists.each do |taobao_onsale_product| 
      exists_taobao_products.tap do |taobao_products|
        taobao_products.each do |taobao_product| 
          taobao_product.upgrade(taobao_onsale_product) if taobao_onsale_product.num_iid == taobao_product.num_iid
        end
      end
    end
    exists_taobao_products.select {|taobao_product| taobao_product.changed? || taobao_product.taobao_skus.any? {|taobao_sku| taobao_sku.new_record? || taobao_sku.changed?} }
  end
end