class WarehousesController < ApplicationController
  before_filter :authorize
  def index
    params[:search] ||= {}
    params[:search].merge!({params[:where_name] => params[:keyword]}) if params[:where_name].present?
    puts params
    @search = Seller.with_account(current_account.id).search(params[:search])
    @warehouses = @search.page(params[:page]).per(20)
  end
end
