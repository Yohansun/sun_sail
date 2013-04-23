class StockBillsController < ApplicationController
 
  before_filter :authenticate_user!
  before_filter :fetch_bills
 
  def fetch_bills
    if current_account.settings.enable_module_third_party_stock == 1
      @bills = StockBill.where(account_id: current_account.id, :confirm_stocked_at.ne => nil).page(params[:page]).per(20)
    else
      @bills = StockBill.where(account_id: current_account.id, :stocked_at.ne => nil).page(params[:page]).per(20)
    end
  end

  def sync
    StockBill.any_in(_id: params[:bill_ids]).each do |bill|
      #PUT INTO QUEUE LATER
      bill.sync 
    end  
    respond_to do |f|
      f.js
    end
  end

  def check
    StockBill.any_in(_id: params[:bill_ids]).each do |bill|
      #PUT INTO QUEUE LATER
      bill.check
    end
    respond_to do |f|
      f.js
    end
  end

  def rollback
    StockBill.any_in(_id: params[:bill_ids]).each do |bill|
      #PUT INTO QUEUE LATER
      bill.rollback 
    end
    respond_to do |f|
      f.js
    end
  end  

end
