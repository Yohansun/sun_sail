module HomeHelper
	def stock_path_by_user
		if current_user.has_role?(:seller) && current_user.seller
			unless current_account.key == 'nippon'
				seller_stocks_path(current_user.seller.id)
			else
				'#'
			end
		elsif current_user.has_role?(:admin)
			stocks_path
		elsif current_user.has_role?(:cs)
			stock_products_path
		else
			'#'
		end
	end
end
