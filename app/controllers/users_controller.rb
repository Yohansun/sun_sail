class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => ['autologin','edit','update']
  before_filter :admin_only!, :except => ['autologin','edit','update']

  def autologin
  	redirect_url = '/'
    user = User.find_by_name params[:username]
    if user && user.magic_key == params[:key]
      sign_in :user, user

      case params[:source]
      when 'fenxiao'
      	redirect_url = '/app#trades/trades-taobao_fenxiao'
      when 'jingdong'
      	redirect_url = '/app#trades/trades-jingdong'
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

  def search
    if  params[:where_name] && params[:keyword].present?
      @users = User.where(["#{params[:where_name]} like ?", "%#{params[:keyword].strip}%"])
      @users = @users.page(params[:page])
    end
    if @users
      render :index
    else
      redirect_to users_path
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
    if @user.active == false
      @user.lock_access!
    end
    if @user.active == true 
      @user.unlock_access!
    end
    if @user.save
      @user.add_role(:cs) if params[:cs] == '1'
      @user.add_role(:cs_read) if params[:cs_read] == '1'
      @user.add_role(:seller) if params[:seller] == '1'
      @user.add_role(:interface) if params[:interface] == '1'
      @user.add_role(:stock_admin) if params[:stock_admin] == '1'
      @user.add_role(:admin) if params[:admin] == '1'
      @user.add_role(:logistic) if params[:logistic] == '1'
      redirect_to users_path
    else
      render :new
    end
  end

  def update
    @user = User.find params[:id]
    if !params[:ac].present?
      @user.username = params[:user][:username] 
      @user.name = params[:user][:name]
      @user.active = params[:user][:active] 
      if @user.active == false 
         @user.lock_access!
      end
      if @user.active == true
        @user.unlock_access!
      end
    end
    @user.email = params[:user][:email] 
    if params[:user][:password].present?
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
    end

    if @user.save
      if !params[:ac].present?
        @user.modify_role("cs",params[:cs])
        @user.modify_role("cs_read",params[:cs_read])
        @user.modify_role("seller",params[:seller])
        @user.modify_role("interface",params[:interface])
        @user.modify_role("stock_admin",params[:stock_admin])
        @user.modify_role("admin",params[:admin])
        @user.modify_role("logistic",params[:logistic])
      end
      redirect_to users_path
    else
      if params[:ac].present? && params[:ac] == "edit"
        render :edit
      else
        render :show
      end
    end
  end

  def edit
    @user = User.find current_user.id
  end
end
