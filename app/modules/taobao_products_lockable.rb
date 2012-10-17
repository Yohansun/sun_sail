# -*- encoding:utf-8 -*-
module TaobaoProductsLockable
	def can_lock_products?(trade, seller_id)
    lockable = []
    trade.orders.each do |order|
      products = StockProduct.joins(:product).where("stock_products.seller_id = #{seller_id} AND products.iid = '#{order.item_outer_id}'")

      if order.color_num.first.present?
        has_product = products.try(:first).try(:activity).to_i > order.num.to_i

        color_sql = "colors.num = '#{order.color_num.first}'"
        products = products.joins(:colors).where(color_sql)

        product = products.first

        unless product && product.activity > order.num
          if has_product
            lockable << "#{order.title}: 无法调色"
          else
            lockable << "#{order.title}: 库存不足"
          end

          next
        end
      else
        product = products.first

        unless product && product.activity > order.num
          lockable << "#{order.title}: 库存不足"
          next
        end
      end
    end

    lockable.uniq
  end
end
