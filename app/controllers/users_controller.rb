# encoding: utf-8
class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => ['autologin','edit','update', 'switch_account']
  before_filter :authorize,:except => [:autologin,:search,:show,:new,:edit,:switch_account,:edit_with_role]

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
    @roles = current_account.roles
  end  

  def show
    @user = current_account.users.find params[:id]
  end

  def new
    @roles = current_account.roles
    @user = current_account.users.new
  end

  def create
    @roles = current_account.roles
    @user = User.new(params[:user])
    @user.accounts << current_account
    if @user.save
      redirect_to users_path
    else
      render :new
    end
  end

  def update
    @user = current_account.users.find params[:id]
    @roles = current_account.roles
    params[:user].except!(:password,:password_confirmation) if params[:user][:password].blank?
    params[:user].except!(:active)                          if current_user == @user

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
    @user = current_account.users.find params[:user_ids].first
    @roles = current_account.roles
  rescue Exception
    redirect_to :action => :index
  end

  def switch_account
    if current_user.has_multiple_account?
      account = current_user.accounts.find(params[:id])
      session[:account_id] = account.id
    end
    redirect_to '/'
  end
  
  def batch_update
    @users = User.where(:id => params[:user_ids])
    
    if @users.count > 10 || @users.exists?(:name => "admin") || @users.exists?(:name => current_user.name)
      flash[:error] = "不能操作自己"
      redirect_to(users_path)
      return true
    end
    
    case params[:operation] 
    when 'lock'
      @users.update_all(:active => true,:locked_at => Time.now)
    when 'unlock'
      @users.update_all(:active => false,:locked_at => nil)
    else
      flash[:error] = "请正常操作"
    end
    redirect_to users_path
  end
  
  def limits
    begin
      @role = current_account.roles.find(params[:role_id]) 
    rescue Exception
      @role = current_account.roles.build
    end
  end
  
  def update_permissions
    prefixs = MagicOrder::AccessControl.permissions.map(&:project_module).uniq
    if params[:role_id].present?
      @role = current_account.roles.find(params[:role_id])
    else
      @role = current_account.roles.build(params[:role])
    end

    #permissions = params[@role.name] || []
    #
    #prefixs.each do |x|
    #  permissions.each do |prefixname|
    #    formats = /(^#{x})(_)(.+)/.match(prefixname)
    #    next if formats.blank?
    #    @permission.merge!({formats[1] => [formats[3]]}) { |x,y,z| y | z} rescue ""
    #  end
    #end
    
    
    @role.permissions =  params[:permissions]
    if @role.update_attributes(params[:role])

      flash[:notice] = "更新成功"
      redirect_to roles_users_path
    else
      render :action => :limits
    end
  end
  
  def destroy_role
    @role = current_account.roles.find(params[:role_id])
    @role.destroy
    redirect_to :action => :roles
  end
  
  def delete
    @users = current_account.users.where(:id => params[:user_ids])
    
    if @users.exists?(:name => "admin") || params[:user_ids].include?(current_user.id.to_s) || @users.count > 10
      flash[:error] = (@users.count > 10 ? "预防恶意操作,请选择10条或以下的用户进行删除." : "不能删除自己")
      redirect_to users_path
    else
      User.where(:id => @users.map(&:id)).delete_all
      redirect_to users_path
    end
  end
end
