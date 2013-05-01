# -*- encoding : utf-8 -*-
class UserActivitiesController < ApplicationController
  before_filter :authorize,:only => [:index,:all]
  def index
    @staffs = redis_operation_log(params[:key_value], -20,-1)
    @count = redis_operation_log_count(params[:key_value])
  end

  def refresh
    @staffs = redis_operation_log(params[:key], params[:count].to_i,-1)
    @count = redis_operation_log_count(params[:key])
    respond_to do |format|
      format.js
    end
  end

  def all
    @pages = params[:pages] || 1
    @count = redis_operation_log_count(params[:key])
    if params[:page]
      page = params[:page].to_i
      if page - -20 == 0
        staffs = redis_operation_log(params[:key], -20,-1)
      else
        staffs = redis_operation_log(params[:key], page,page - -20)
      end
    else
      staffs = redis_operation_log(params[:key], -20,-1)
    end

    @staffs = Kaminari.paginate_array(staffs.sort {|x,y| y<=>x}).page(params[:page]).per(20)
  end

  def redis_operation_log(key,start,stop)
    if key.present?
      key = key.to_i
      if key == 1
        $redis.ZRANGE "account:#{current_account.id}:OperationLogToCs", start, stop
      elsif key == 2
        $redis.ZRANGE "account:#{current_account.id}:OperationLogToAdmin", start, stop
      elsif key == 3
        $redis.ZRANGE "account:#{current_account.id}:OperationLogToSeller", start, stop
      else
        $redis.ZRANGE "account:#{current_account.id}:OperationLogToAll", start, stop
      end
    else
      $redis.ZRANGE "account:#{current_account.id}:OperationLogToAll", start, stop
    end
  end

  def redis_operation_log_count(key)
    if key.present?
      key = key.to_i
      if key == 1
        $redis.ZCOUNT "account:#{current_account.id}:OperationLogToCs", "-inf", "+inf"
      elsif key == 2
        $redis.ZCOUNT "account:#{current_account.id}:OperationLogToAdmin", "-inf", "+inf"
      elsif key == 3
        $redis.ZCOUNT "account:#{current_account.id}:OperationLogToSeller", "-inf", "+inf"
      else
        $redis.ZCOUNT "account:#{current_account.id}:OperationLogToAll", "-inf", "+inf"
      end
    else
      $redis.ZCOUNT "account:#{current_account.id}:OperationLogToAll", "-inf", "+inf"
    end
  end
end
