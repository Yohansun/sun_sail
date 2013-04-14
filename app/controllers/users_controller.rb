# encoding: utf-8
class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => ['autologin','edit','update', 'switch_account']
  before_filter :admin_only!, :except => ['autologin','edit','update']

  def autologin
  	redirect_url = '/'
    user = current_account.users.find_by_name params[:username]
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
      @users = current_account.users.where("name LIKE '%#{params[:name]}%'")
    elsif params[:seller_id].present?
      @users = current_account.users.where(seller_id: params[:seller_id])
    else
      @users = current_account.users.page params[:page]
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

  def roles
    @roles = Role.all
  end  

  def show
    @user = current_account.users.find params[:id]
  end

  def new
    @roles = Role.all
    @user = current_account.users.new
  end

  def create
    @roles = Role.all
    @user = current_account.users.new(params[:user])
    @user.accounts << current_account
    if @user.save
      redirect_to users_path
    else
      render :new
    end
  end

  def update
    @user = current_account.users.find params[:id]
    @roles = Role.all
    params[:user].except!(:active) if current_user == @user

    if @user.update_attributes(params[:user])
      @user.active == true ? @user.unlock_access! : @user.lock_access!
      redirect_to users_path
    else
      render :action => params[:from_path] || :edit
    end
  end

  def edit
    @user = current_account.users.find current_user.id
  end
  
  def edit_with_role
    @user = current_account.users.find params[:user_id]
    @roles = Role.all
  rescue Exception
    redirect_to :action => :index
  end

  def lock_users

  end  

  def switch_account
    if current_user.has_multiple_account?
      account = current_user.accounts.find(params[:id])
      session[:account_id] = account.id
    end
    redirect_to '/'
  end
  
  def limits
    begin
      @role = Role.find(params[:role_id]) 
    rescue Exception
      @role = Role.last
      params[:role_id] = @role.id
    end
  end
  
  def update_permissions
    prefixs = MagicOrder::AccessControl.permissions.map(&:project_module).uniq
    @role = Role.find(params[:role_id])
    @permission = {}
    permissions = params[@role.name] rescue []

    prefixs.each do |x|
      permissions.each do |prefixname|
        formats = /(^#{x})(_)(.+)/.match(prefixname)
        next if formats.blank?
        @permission.merge!({formats[1] => [formats[3]]}) { |x,y,z| y | z} rescue ""
      end
    end
    
    
    @role.permissions = {@role.name => @permission}
    if @role.save

      flash[:notice] = "更新成功"
      redirect_to roles_users_path
    else
      render :action => :limits
    end
  end
end
