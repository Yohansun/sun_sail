# -*- encoding : utf-8 -*-

class TradeSourcesController < ApplicationController
   respond_to :json

   def index
      @trade_sources = TradeSource.all
      respond_with @trade_sources
   end	

   def show
   	@trade_source = TradeSource.where(id: params[:id]).first
   	respond_with @trade_source
   end	

   def update
   	@trade_source = TradeSource.where(id: params[:id]).first
      
      unless params[:app_key].blank?
         @trade_source.app_key = params[:app_key].strip
      end

      unless params[:secret_key].blank?
         @trade_source.secret_key = params[:secret_key].strip
      end
      
      unless params[:session].blank?
         @trade_source.session = params[:session].strip
      end

      @trade_source.fetch_quantity = params[:fetch_quantity].to_i
      @trade_source.fetch_time_circle = params[:fetch_time_circle].to_i
      @trade_source.high_pressure_valve = params[:high_pressure_valve]

      @trade_source.save!

   	respond_with @trade_source

   end

end   
