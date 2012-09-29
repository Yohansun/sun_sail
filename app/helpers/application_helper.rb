module ApplicationHelper
	def	user_stock_path
		return '#' unless current_user
		if current_user.has_role? :admin
			"/stocks"
		else
			if current_user.seller?
				"/sellers/#{current_user.seller_id}/stocks"
			else
				'#'
			end
		end
	end
end
