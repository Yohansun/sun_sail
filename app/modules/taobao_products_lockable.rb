# -*- encoding:utf-8 -*-
module TaobaoProductsLockable
	def can_lock_products?(trade, seller_id)
    lockable = []
    trade.orders.each do |order|
      products = StockProduct.joins(:product).where("stock_products.seller_id = #{seller_id} AND products.iid = '#{order.item_outer_id}'")

      if order.color_num.present?
        has_product = products.first && products.first.activity > order.num

        color_sql = "colors.num = '#{order.color_num.first}'"
        products = products.joins(:colors).where(color_sql)

        product = products.first

        unless product && product.activity > order.num
          if has_product
            lockable << '商品库存不足'
          else
            lockable << '商品无法调色'
          end

          next
        end
      else
        product = products.first

        unless product && product.activity > order.num
          lockable << '商品库存不足'
          next
        end
      end
    end

    lockable.uniq
  end
end
