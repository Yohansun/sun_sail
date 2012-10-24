# -*- encoding:utf-8 -*-
module TaobaoProductsLockable
	def can_lock_products?(trade, seller_id)
    lockable = []
    trade.orders.each do |order|
      product = StockProduct.joins(:product).where("stock_products.seller_id = #{seller_id} AND products.iid = '#{order.item_outer_id}'").first
      has_product = product.present? && (product.activity > order.num)

      colors = order.color_num.flatten.compact
      colors.delete('')

      if has_product
        if (colors - product.colors.map(&:num)).size > 0
          lockable << "#{order.title}: 无法调色"
        end
      else
        lockable << "#{order.title}: 库存不足"
      end
    end

    lockable.uniq
  end
end
