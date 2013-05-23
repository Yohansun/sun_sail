#encoding: utf-8
class CustomersController < ApplicationController
  before_filter :authorize
  ACTIONS = {:index => "所有顾客",:potential => "潜在顾客",:paid => "购买顾客"}
  
  ACTIONS.each_pair do |_action,name|
    define_method(_action) do
      params[:search] ||= {}
      params[:search][:account_id_eq] = current_account.id
      op_state,op_city,op_district = params["op_state"],params["op_city"], params["op_district"]
      search  = params[:search]
      search["transaction_histories_receiver_state_eq"]     = Area.find_by_id(op_state).try(:name)    if op_state.present?
      search["transaction_histories_receiver_city_eq"]      = Area.find_by_id(op_city).try(:name)     if op_city.present?
      search["transaction_histories_receiver_district_eq"]  = Area.find_by_id(op_district).try(:name) if op_district.present?
      
      @search = if _action == :index
        Customer.search(params[:search])
      else
        Customer.send(_action).search(params[:search])
      end
      @customers = @search.page(params[:page]).per(20)
      respond_to do |format|
        format.html {render "index" if _action != :index}
        format.xls  {render "index"}
      end
    end
  end
end
