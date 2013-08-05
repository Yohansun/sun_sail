# -*- encoding:utf-8 -*-
module StockProductsLockable
  def can_lock_products?(trade_id, seller_id)
    error_messages = []
    trade = Trade.find(trade_id)
    seller = Seller.find_by_id(seller_id)
    trade.orders.each do |order|
      package_info = order.package_info
      package_info.each do |info|
        title = info.fetch(:title)
        color_num = order.color_num
        sku_id = info.fetch(:sku_id)
        sku = Sku.find_by_sku_id(sku_id)
        stock_product = seller.stock_products.where(id: info.fetch(:stock_product_ids)).first
        has_product = stock_product.present?
        if has_product
          has_not_enough_activity = stock_product.activity < info.fetch(:number)
          if has_not_enough_activity
            error_messages << "#{title}: 商品不存在"
          end
          need_colors = []
          if color_num.present?
            color_num.each do |colors|
              next if colors.blank?
              colors = colors.shift(pp[:number]).flatten.compact.uniq
              colors.delete('')
              need_colors += colors
            end
            avaliable_colors = sku.product.product.colors.map(&:num)
            not_exit_colors = need_colors - avaliable_colors
            if not_exit_colors.present?
              error_messages << "#{title}: 无法调色"
            end
          end
        else
          error_messages << "#{title}: 库存不足"
        end
      end
    end
    error_messages.uniq
  end
end
