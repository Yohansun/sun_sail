class StockBillsController < ApplicationController
  before_filter :authenticate_user!
  def index
    if current_account.settings.enable_module_third_party_stock == 1
      bills = StockBill.where(account_id: current_account.id, :confirm_stocked_at.ne => nil).desc(:succeded_at)
      unchecked, checked = bills.partition { |b| b.confirm_stocked_at.nil? }
    else
      bills = StockBill.where(account_id: current_account.id, :checked_at.ne => nil).desc(:succeded_at)
      unchecked, checked = bills.partition { |b| b.checked_at.nil? }
    end   
    @bills = unchecked + checked  
  end
end
