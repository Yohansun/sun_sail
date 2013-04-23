class StockInBillsController < ApplicationController
	before_filter :authenticate_user!
  before_filter :fetch_bills

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

  def fetch_bills
    bills = StockInBill.where(account_id: current_account.id).desc(:checked_at)
    unchecked, checked = bills.partition { |b| b.checked_at.nil? }
    @bills = unchecked + checked  
    @bills = Kaminari.paginate_array(@bills).page(params[:page]).per(20) 
  end 

end
