class TradeReportsController < ApplicationController
	before_filter :authenticate_user!

	def index
		reports = TradeReport
		unless current_user.has_role?(:admin)
			reports = reports.where(user_id: curren_user.id)
		end	
		@reports = reports.page params[:page]
	end	

	def show
    send_data open("#{Rails.root}/data/trade_reports/#{params[:id]}.xls").read, :filename => "#{params[:id]}.xls"
  end
end
