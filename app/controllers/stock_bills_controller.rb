class StockBillsController < ApplicationController

  before_filter :authorize,:except => :fetch_bils
  before_filter :fetch_bills
  
  def index
    params[:search] ||= {}
    params[:search][:_id_in] = params[:export_ids].split(',') if params[:export_ids].present?
    @search = @bills.search(params[:search])
    @bills = @search.page(params[:page]).per(20)
    @count = @search.count
  end

  def fetch_bills
    if current_account.settings.enable_module_third_party_stock == 1
      @bills = StockBill.where(account_id: current_account.id, :confirm_stocked_at.ne => nil)
    else
      @bills = StockBill.where(account_id: current_account.id, :stocked_at.ne => nil)
    end
  end

end
