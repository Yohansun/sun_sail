# -*- encoding : utf-8 -*-
class LogisticsController < ApplicationController
  layout "management"
  before_filter :authorize

  def index
    @logistics = current_account.logistics.page(params[:page])
  end

  def new
    @logistic = current_account.logistics.new
  end

  def create
    params[:logistic][:code].try(:upcase!)
    @logistic = current_account.logistics.new params[:logistic]
    @logistic.build_print_flash_setting
    if @logistic.save
      redirect_to logistics_path
    else
      render :new
    end
  end

  def edit
    @logistic = current_account.logistics.find params[:id]
    render :edit
  end

  def update
    @logistic = current_account.logistics.find params[:id]
    params[:logistic][:code].upcase!
    if @logistic.update_attributes params[:logistic]
      redirect_to logistics_path
    else
      render :new
    end
  end

	def delete
		logistics = current_account.logistics.find params[:id]
		Logistic.destroy(logistics)
		redirect_to logistics_path
	end

  def deletes
    @ids = params[:ids].split(",")
    current_account.logistics.where(:id=>@ids).destroy_all
    redirect_to logistics_path
  end

	def logistic_area
    @logistics = LogisticArea.where(logistic_id: params[:logistic_id]).all
    respond_to do |f|
      f.js
    end
  end

  def create_logistic_area
  	logistic_area = LogisticArea.where(logistic_id: params[:logistic_id],area_id: params[:area_id])
    if !logistic_area.present?
      logistic_area = LogisticArea.new
      logistic_area.logistic_id = params[:logistic_id]
      logistic_area.area_id = params[:area_id]
      logistic_area.save
    end
    @logistics = LogisticArea.where(logistic_id: params[:logistic_id]).all
    respond_to do |f|
      f.js
    end
  end

  def remove_logistic_area
  	if params[:logistic_id] && params[:area_id]
      logistic_area = LogisticArea.select("id,area_id").where(logistic_id: params[:logistic_id],area_id: params[:area_id]).first
    end
    if params[:id]
      logistic_area = LogisticArea.find params[:id]
    end
    if logistic_area.present?
      @area_id = logistic_area.area_id
      logistic_area.destroy
    end
    respond_to do |f|
      f.js
    end
  end

  def logistic_user
    @logistic_user = User.where(logistic_id: params[:logistic_id])
    respond_to do |f|
      f.js
    end
  end

  def user_list
    users = current_account.users

    if params[:user_name].present?
      @user = User.where(["users.logistic_id is null and users.name like ?", "%#{params[:user_name].strip}%"])
    else
      @user = User.where(:logistic_id => nil)
    end
    respond_to do |f|
      f.js
    end
  end

  def logistic_user_list
    @flag = false
    user = User.find params[:u_id]
    user.logistic_id = params[:logistic_id]
    user.add_role :logistic
    if user.save
      @flag = true
    else
      @flag = false
    end
    @logistic_user_list = User.where(logistic_id: user.logistic_id)
    respond_to do |f|
      f.js
    end
  end

  def remove_logistic_user
    user = User.find params[:u_id]
    user.logistic_id = nil
    user.remove_role :logistic
    user.save
    respond_to do |f|
      f.js
    end
  end

  def logistic_templates
    tmp = []
    @logistics = current_account.logistics
    unless params[:type] && params[:type] == 'all'
      @logistics = @logistics.where("xml is not null")
    end
    if params[:trade_type].present? && params[:trade_type] != "CustomTrade"
      source_type = params[:trade_type].underscore.gsub(/_trade$/,'')
    end
    # TODO
    # 默认使用统一平台下的第一个店铺的物流商信息
    # 鉴于这一块如果做好的话得取同一平台下所有店铺物流商的集, 逻辑有点不清晰,而且代码量比较多, 而且这么做下来未必就是最好的解决方案.
    # 最好的就是本地物流信息绑定第三方物流商,如果第三方平台中的某个店铺更新了物流信息,在本地发货的时候没有找到, 或物流商信息变更了,
    # 导致发货失败,提示更新第三方物流,并手动绑定后在发货.
    method = source_type.to_s.dup << "_sources"
    trade_source = current_account.respond_to?(method) && current_account.send(method).first
    @logistics.each do |l|
      tmp << {
        id: l.id,
        service_logistic_id: params[:trade_type] != "CustomTrade" ? (l.send("#{source_type}_logistic_id",trade_source.id) rescue nil) : l.id,
        xml: l.xml.inspect,
        name: l.name
      }
    end
    render json: tmp.reject {|h| h[:service_logistic_id].blank?}
  end

  def all_logistics
    tmp = []
    @logistics = Logistic.with_account(current_account.id)
    @logistics.each do |l|
      tmp << {
        id: l.id,
        xml: l.xml.inspect,
        name: l.name
      }
    end

    render json: tmp
  end

end
