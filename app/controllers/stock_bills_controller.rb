class StockBillsController < ApplicationController

  before_filter :authorize,:except => :fetch_bils
  before_filter :fetch_bills
  
  def index
    parse_params
    if /(?<sku_type>bill_products_sku_id_eq|bill_products_num_iid_eq)/ =~ params[:sku]
      params[:search]["#{sku_type}"] = params[:sku].gsub("#{sku_type}",'')
    end
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
  
  def parse_params
    search = params[:search] ||= {}
    params[:search][:_id_in] = params[:export_ids].split(',') if params[:export_ids].present?
    if params[:bill_products_sku_id_eq].present?
      search[:bill_products_sku_id_eq] = params[:bill_products_sku_id_eq]
    end
    if params[:checked_at] == "nil"
      search[:checked_at_not_eq] = nil
    elsif params[:checked_at] == "true"
      search[:checked_at_eq] = nil
    end
  end
end
