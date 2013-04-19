class StockInBillsController < ApplicationController
	before_filter :authenticate_user!
	def new
    @bill = StockInBill.new(account_id: current_account.id)
  end

  def create
    @bill = StockInBill.new(account_id: current_account.id) 
    if @bill.update_attributes(params[:bill])
      redirect_to stock_in_bills_path
    else
      render :new
    end
  end

  def index
    bills = StockInBill.where(account_id: current_account.id).desc(:checked_at)
    unchecked, checked = bills.partition { |b| b.checked_at.nil? }
    @bills = unchecked + checked   
  end

end
