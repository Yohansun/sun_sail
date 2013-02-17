# -*- encoding:utf-8 -*-
module TaobaoProductsLockable
	def can_lock_products?(trade, seller_id)
    lockable = []
    trade.orders.each do |order|
      op = Product.find_by_iid order.outer_iid

      if op.blank?
        lockable << "#{order.title}: 库存不足"
        next
      end

      op_package = op.package_info
      color_num = order.color_num
      color_num.delete('')
      op_package << {
        iid: order.outer_iid,
        number: order.num,
        title: order.title
      } if op_package.blank?

      op_package.each do |pp|
        product = StockProduct.joins(:product).where("stock_products.seller_id = #{seller_id} AND products.iid = '#{pp[:iid]}'").first
        has_product = product.present? && (product.activity > pp[:number])
        p_colors = []

        if trade.fetch_account.settings.enable_match_seller_user_color and color_num.present?
          color_num.each do |colors|
            next if colors.blank?
            colors = colors.shift(pp[:number]).flatten.compact.uniq
            colors.delete('')
            p_colors += colors
          end
        end

        if has_product
          if (p_colors - product.colors.map(&:num)).size > 0
            lockable << "#{pp[:title]}: 无法调色"
          end
        else
          lockable << "#{pp[:title]}: 库存不足"
        end
      end
    end

    lockable.uniq
  end
end
