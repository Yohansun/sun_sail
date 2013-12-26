# -*- encoding : utf-8 -*-
class LogisticAreasController < ApplicationController
  layout "management"
  before_filter :authorize

  def index
    @logistic = current_account.logistics.find params[:logistic_id]
    @logistic_areas = @logistic.logistic_areas.page(params[:page]).per(50)
  end

  def update_post_info
    @logistic = current_account.logistics.find params[:logistic_id]
    @logistic.update_attributes(params[:default_post_info])
    if params[:logistic_areas]
      params[:logistic_areas].each do |area_id, post_info|
        @logistic.logistic_areas.find(area_id).update_attributes(post_info)
      end
    end
    flash[:notice] = "保存成功"
    redirect_to logistics_path
  end
end