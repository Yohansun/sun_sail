#encoding: utf-8
class CustomersController < ApplicationController
  before_filter :authorize
  before_filter :init_search
  ACTIONS = {:index => "所有顾客",:potential => "潜在顾客",:paid => "购买顾客"}
  ALL_ACTIONS = ACTIONS.dup.merge({:around => "回头顾客"})
  
  ACTIONS.each_pair do |_action,name|
    define_method(_action) do
      
      @search = if _action == :index
        Customer.search(params[:search])
      else
        Customer.send(_action).search(params[:search])
      end
      @number = 20
      @number = params[:number] if params[:number].present?
      @customers = @search.page(params[:page]).per(@number)
      respond_to do |format|
        format.html {render "index" if _action != :index}
        format.xls  {render "index"}
      end
    end
  end

  #GET /customers/1
  def show
    id = params[:search][:_id_in].first rescue params[:id]
    @customer = Customer.where(account_id: current_account.id).find(id)
    fresh_when :last_modified => @customer.updated_at.utc,:etag => @customer
  end

  #GET /customers/around
  def around
    @products = Product.includes(:category).all
    @search = Customer.search(params[:search])
    @customers = @search.page(params[:page]).per(20)
    respond_to do |format|
      format.html
      format.xls
    end
  end

  #GET /customers/send_messages
  def send_messages
    @product_ids = params[:product_ids].to_s.split(',').map(&:to_i)
    @customers = Customer.search(params[:search])
    @transaction_histories = @customers.map(&:transaction_histories).flatten
    @transaction_histories = @transaction_histories.reject {|x| (x.product_ids & @product_ids).blank?}
    @message = Message.new(:send_type => "sms",:recipients => @transaction_histories.map(&:receiver_mobile).join(','))
  end

  #POST /customers/invoice_messages
  def invoice_messages
    @message = Message.new(params[:message])
    @customers = Customer.search(params[:search])
    @message.ip = request.remote_ip
    @message.perator = current_user.username
    @message.account_id = current_account.id
    if @message.save
      flash[:notice] = "发送中..."
      redirect_to :action => :send_messages
    else
      flash[:error] = "发送失败"
      render :action => :send_messages
    end
  end

  #GET /customers/get_recipients
  def get_recipients
    send_type = params[:send_type]
    @product_ids = params[:product_ids].split(',').map(&:to_i) rescue []
    @customers = Customer.search(:transaction_histories_product_ids_in => @product_ids)
    @transaction_histories = @customers.map(&:transaction_histories).flatten
    @transaction_histories = @transaction_histories.reject {|x| (x.product_ids & @product_ids).blank?}
    case params[:send_type]
    when "mail"
      @text = @customers.map(&:email).join(",")
    when "sms"
      @text = @transaction_histories.collect {|x| x.receiver_mobile}.join(',')
    end

    respond_to do |format|
      format.js {render :text => @text }
    end
  end

  private
  def init_search
    params[:search] ||= {}
    params[:search][:account_id_eq] = current_account.id
    op_state,op_city,op_district = params["op_state"],params["op_city"], params["op_district"]
    search  = params[:search]
    search["transaction_histories_status_eq"] = "TRADE_FINISHED" if params[:action] == "around"
    #可用于多选
    search.delete("transaction_histories_status_in")             if search["transaction_histories_status_in"] == [""]

    search["transaction_histories_receiver_state_eq"]     = Area.find_by_id(op_state).try(:name)    if op_state.present?
    search["transaction_histories_receiver_city_eq"]      = Area.find_by_id(op_city).try(:name)     if op_city.present?
    search["transaction_histories_receiver_district_eq"]  = Area.find_by_id(op_district).try(:name) if op_district.present?
    if params[:use_days].present?
      @range = Range.new *params[:use_days].split("-") rescue 0..0
      category_ids = Category.where(:account_id => current_account.id,:use_days => @range).map(&:id)
      condition = Product.where(:category_id => category_ids).select(:id).to_sql
      @product_ids = Product.connection.select_values(condition)
      search["transaction_histories_product_ids_in"] = @product_ids
    end
  end
end
