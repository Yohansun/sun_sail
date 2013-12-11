# encoding: utf-8

class Order
  include Mongoid::Document
  include Mongoid::Timestamps
  include MagicEnum

  field :oid, type: String
  field :refund_status, type: String, default: "NO_REFUND"
  field :local_sku_id, type: Integer

  field :total_fee, type: Float, default: 0.0
  field :payment, type: Float, default: 0.0
  field :discount_fee, type: Float, default: 0.0
  field :adjust_fee, type: Float

  field :cs_memo, type: String                    # 客服备注

  field :color_num, type: Array, default: []      # 调色字段
  field :color_hexcode, type: Array, default: []
  field :color_name, type: Array, default: []
  field :barcode, type: Array, default: []        # 条形码

  #赠品子订单专用field
  field :order_gift_tid, type: String

  validates_uniqueness_of :order_gift_tid, allow_blank: true

  def trade
    #OVERWRITTEN BY SUBCLASS
  end

  def account_id
    trade.account_id
  end

  def skus
    #OVERWRITTEN BY SUBCLASS
  end

  def sku_bindings
    #OVERWRITTEN BY SUBCLASS
  end

  def local_skus
    sku = Sku.find_by_id(local_sku_id)
    sku == nil ? [] : [sku]
  end

  def products
    skus.map(&:product)
  end

  def categories
    products.map(&:category)
  end

  def skus_info
    tmp = skus.collect do |sku|
      next unless sku && sku.product
      {
        name:               sku.product.name,
        outer_id:           sku.product.outer_id,
        product_id:         sku.product.id,
        product_price:      sku.product.price,
        category_name:      sku.product.category.name,
        number:             self.num * (sku_bindings.present? && sku_bindings.find_by_sku_id(sku.id).try(:number) || 1),
        stock_product_ids:  sku.stock_product_ids,
        sku_id:             sku.id,
        sku_title:          sku.title
      }
    end
  end

  def skus_info_with_offline_refund
    adapted_skus_info = self.skus_info
    adapted_skus_info.each do |info|
      if trade.refund_ref_status == '确认线下退款'
        ref_order = trade.refund_ref.ref_orders.where(sku_id: info[:sku_id]).first
        info[:number] -= ref_order.num if ref_order
        adapted_skus_info.delete(info) if info[:number] == 0
      end
    end
    adapted_skus_info
  end

  def package_products
    info = []
    if sku_bindings.present?
      sku_bindings.each do |binding|
        product = binding.sku.try(:product)
        number = binding.number
        info << Array.new(number,product)
      end
    elsif local_skus.present?
      local_skus.each do |sku|
        product = sku.product
        info << Array.new(self.num,product)
      end
    end
    info = info.flatten
  end
end