module TaobaoProductsLockable
	def can_lock_products?(seller_id)
    lockable = true
    orders.each do |order|
      product = StockProduct.joins(:product).where("stock_products.seller_id = #{seller_id} AND products.iid = '#{order.item_outer_id}'").first
      lockable = false unless product && product.activity > order.num
    end

    lockable
  end
end