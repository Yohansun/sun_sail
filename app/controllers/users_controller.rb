# encoding: utf-8
class UsersController < ApplicationController
  layout "management", except: [:show_me]
  before_filter :authorize #,:except => [:autologin,:search,:edit_with_role]

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
    users = current_account.users
    users = users.where(superadmin:false) if !current_user.superadmin?
    admin_role = Role.find_by_name "admin"
    users = users.includes(:roles).where("roles.id != ?", admin_role.id) if !current_user.roles.include? admin_role

    if params[:name].present?
      @users = users.where("name LIKE '%#{params[:name]}%'")
    elsif params[:seller_id].present?
      @users = users.where(seller_id: params[:seller_id])
    else
      @users = users.page params[:page]
    end
  end

  def search
    users = current_account.users
    users = users.where(superadmin:false) if !current_user.superadmin?
    admin_role = Role.find_by_name "admin"
    users = users.includes(:roles).where("roles.id != ?", admin_role.id) if !current_user.roles.include? admin_role

    if  params[:where_name] && params[:keyword].present?
      @users = users.where(["#{params[:where_name]} like ?", "%#{params[:keyword].strip}%"])
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

  def show_me
    @user = current_user
  end

  def new
    @roles = current_account.roles
    @user = current_account.users.new
  end

  def create
    @roles = current_account.roles
    @user = User.new(params[:user])
    user_roles = current_account.roles.where("id in (?)", params[:user][:role_ids])
    @user.can_assign_trade = user_roles.inject(false){|status, el| status || el.can_assign_trade}
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
    user_roles = current_account.roles.where("id in (?)", params[:user][:role_ids])
    @user.can_assign_trade = user_roles.inject(false){|status, el| status || el.can_assign_trade}
    params[:user].except!(:password,:password_confirmation) if params[:user][:password].blank?
    params[:user].except!(:active)                          if current_user == @user

    params[:user][:role_ids] = nil if params[:user][:role_ids].blank?
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
    @user = current_account.users.find params[:id]
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

  #POST /users/batch_update
  def batch_update
    @users = User.where(:id => params[:user_ids])

    if @users.count > 10 || @users.exists?(:name => "admin") || @users.exists?(:name => current_user.name)
      flash[:error] = "不能操作自己"
      redirect_to(users_path)
      return true
    end

    case params[:operation]
    when 'lock'
      flash[:notice] = "锁定成功!"
      @users.update_all(:active => false,:locked_at => Time.now)
    when 'unlock'
      flash[:notice] = "解锁成功!"
      @users.update_all(:active => true,:locked_at => nil)
    else
      flash[:error] = "请正常操作"
    end
    redirect_to users_path
  end

  # GET /users/limits
  def limits
    begin
      @role = current_account.roles.find(params[:role_id])
    rescue Exception
      @role = current_account.roles.build
    end
  end

  # PUT /users/create_role
  def create_role
    @role = current_account.roles.build(params[:role])
    if @role.save
      flash[:notice] = "创建成功"
      redirect_to :action => :roles
    else
      render :text => ((view_context.link_to "返回", roles_users_path) + view_context.tag("br") + @role.errors.full_messages.join('</br>') )
    end
  end

  def update_permissions
    prefixs = MagicOrder::AccessControl.permissions.map(&:project_module).uniq
    @role = current_account.roles.find(params[:role_id])

    #permissions = params[@role.name] || []
    #
    #prefixs.each do |x|
    #  permissions.each do |prefixname|
    #    formats = /(^#{x})(_)(.+)/.match(prefixname)
    #    next if formats.blank?
    #    @permission.merge!({formats[1] => [formats[3]]}) { |x,y,z| y | z} rescue ""
    #  end
    #end

    @role.permissions =  params[:permissions] if params.key?(:permissions)
    @role.can_assign_trade = (params[:can_assign_trade] == "on" ? true : false)
    @role.reset_assign_trade
    if @role.update_attributes(params[:role])
      flash[:notice] = "更新成功"
      redirect_to roles_users_path
    else
      flash[:error] = @role.errors.full_messages.uniq.join(',')
      render :action => :limits
    end
  end

  def update_visible_columns
    action_name = params[:action_name]
    visible_columns = if params[:visible_columns].present?
                        params[:visible_columns]
                      else
                        []
                      end
    case params[:model_name]
    when "customer"
      if ["index", "potential", "paid", "around"].include?(action_name)
        visible_cols = current_account.settings.customer_visible_cols
        visible_cols[action_name] = visible_columns
        current_account.settings["customer_visible_cols"] = visible_cols
      end
    when "stock_in_bill"
      current_account.settings["stock_in_bill_visible_cols"] = visible_columns
    when "stock_out_bill"
      current_account.settings["stock_out_bill_visible_cols"] = visible_columns
    when "stock_bill"
      current_account.settings["stock_bill_visible_cols"] = visible_columns
    when "stock_product"
      if ["stock_product_all_visible_cols", "stock_product_detail_visible_cols"].include?(action_name)
        current_account.settings[action_name] = visible_columns
      end
    when "product"
      current_account.settings["product_visible_cols"] = visible_columns
    when "taobao_product"
      current_account.settings["taobao_product_visible_cols"] = visible_columns
    end
    render :json => {status: "success"}
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
