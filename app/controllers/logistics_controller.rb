# -*- encoding : utf-8 -*-
class LogisticsController < ApplicationController
	def index
		@logistics = Logistic.page(params[:page])
	end

	def new
		@logistics = Logistic.new
	end

	def create
		@logistics = Logistic.new
		@logistics.name = params[:logistic][:name]
		if @logistics.save
			redirect_to logistics_path
    else
      render :new
    end
	end

	def edit
		@logistics = Logistic.find params[:id]
		render :new
	end

	def update
		@logistics = Logistic.find params[:id]
		@logistics.name = params[:logistic][:name]
		if @logistics.save
			redirect_to logistics_path
    else
      render :new
    end
	end

	def delete
		logistics = Logistic.find params[:id]
		Logistic.destroy(logistics)
		redirect_to logistics_path
	end

	def logistic_area    
		logger.debug(params[:logistic_id])
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
end
