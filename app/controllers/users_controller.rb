class UsersController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

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
    @users = User.all
    respond_with @users
  end

  def show
    @user = User.find params[:id]
    respond_with @user
  end
  
  def create
    @user = User.new
    @user.username = params[:username]
    @user.name = params[:name]
    @user.email = params[:email]
    @user.password = params[:password]
    @user.password_confirmation = params[:password_confirmation]

    @user.save!

    @user.add_role(:support) if params[:is_support] == true
    @user.add_role(:seller) if params[:is_seller] == true
    @user.add_role(:interface) if params[:is_interface] == true
    @user.add_role(:stock_admin) if params[:is_stock_admin] == true

    respond_with @user
  end

  def update
    @user = User.find params[:id]
    @user.username = params[:username]
    @user.name = params[:name]
    @user.email = params[:email]
    if params[:password].present?
      @user.password = params[:password]
      @user.password_confirmation = params[:password_confirmation]
    end

    @user.save!

    if params[:is_support] == true
      @user.add_role(:support) 
    else
      @user.remove_role :support
    end
    if params[:is_seller] == true
      @user.add_role(:seller) 
    else
      @user.remove_role(:seller)
    end 
    if params[:is_interface] == true
      @user.add_role(:interface) 
    else
      @user.remove_role(:interface) 
    end
    if params[:is_stock_admin] == true
      @user.add_role(:stock_admin)
    else
      @user.remove_role(:stock_admin)
    end

    respond_with @user
  end

end
