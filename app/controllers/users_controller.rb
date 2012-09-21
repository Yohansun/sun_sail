class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => ['autologin']

  def autologin
  	redirect_url = '/'
    user = User.find_by_name params[:username]
    if user && user.magic_key == params[:key]
      sign_in :user, user

      case params[:source]
      when 'fenxiao'
      	redirect_url = '/trades/taobao_fenxiao'
      when 'jingdong'
      	redirect_url = '/trades/jingdong'
      end
    end

    redirect_to redirect_url
  end

  def index
    if params[:name].present?
      @users = User.where("name LIKE '%#{params[:name]}%'")
    elsif params[:seller_id].present?
      @users = User.where(seller_id: params[:seller_id])
    else
      @users = User.page params[:page]
    end
  end

  def show
    @user = User.find params[:id]
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      @user.add_role(:support) if params[:support] == '1'
      @user.add_role(:seller) if params[:seller] == '1'
      @user.add_role(:interface) if params[:interface] == '1'
      @user.add_role(:stock_admin) if params[:stock_admin] == '1'
      redirect_to users_path
    else
      render :new
    end 
  end

  def update
    @user = User.find params[:id]
    @user.username = params[:user][:username]
    @user.name = params[:user][:name]
    @user.email = params[:user][:email]
    @user.active = params[:user][:active]
    if params[:user][:password].present?
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
    end

    if @user.save
      @user.modify_role("support",params[:support])
      @user.modify_role("seller",params[:seller])
      @user.modify_role("interface",params[:interface])
      @user.modify_role("stock_admin",params[:stock_admin])
      redirect_to users_path
    else
      render :show
    end

  end

end
