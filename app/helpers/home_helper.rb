module HomeHelper
	def stock_path_by_user
		if current_user.allow_read?(:stocks)
			stocks_path
		elsif current_user.allowed_to?("stock_products","index")
			stock_products_path
		else
			'#'
		end
	end
end