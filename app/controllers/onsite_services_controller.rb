# -*- encoding : utf-8 -*-
class OnsiteServicesController < ApplicationController

  def index

    @states = Area.roots

    if params[:keyword] && params[:value].present?
      @states = @states.where(["#{params[:keyword]} like ?", "%#{params[:value].strip}%"])
    end

    @states = @states.page(params[:page]) 
  end

  def onsite_service_area
    @state = Area.find_by_id(params[:state_id])
    @onsite_service_areas = @state.onsite_service_areas(current_account.id)
    respond_to do |f|
      f.js
    end
  end

  def create_onsite_service_area
    @area = Area.find_by_id(params[:area_id])
    @state = @area.ancestors.roots.first
    OnsiteServiceArea.create(area_id: params[:area_id], account_id: current_account.id)
    @onsite_service_areas = @state.onsite_service_areas(current_account.id)
    respond_to do |f|
      f.js
    end
  end

  def remove_onsite_service_area
    @state = Area.find_by_id(params[:state_id])
    OnsiteServiceArea.where(area_id: params[:area_id], account_id: current_account.id).delete_all
    @onsite_service_areas = @state.onsite_service_areas(current_account.id)
    respond_to do |f|
      f.js
    end
  end	
end
