# -*- encoding : utf-8 -*-
class TradeSourcesController < ApplicationController
   before_filter :authenticate_user!
   before_filter :admin_only!

   def show
      @trade_source = current_account.trade_sources.where(id: params[:id]).first
   end

   def update
      @trade_source = current_account.trade_sources.where(id: params[:id]).first

      unless params[:trade_source][:app_key].blank?
         @trade_source.app_key = params[:trade_source][:app_key].strip
      end

      unless params[:trade_source][:secret_key].blank?
         @trade_source.secret_key = params[:trade_source][:secret_key].strip
      end

      unless params[:trade_source][:session].blank?
         @trade_source.session = params[:trade_source][:session].strip
      end

      @trade_source.fetch_quantity = params[:trade_source][:fetch_quantity].to_i
      @trade_source.fetch_time_circle = params[:trade_source][:fetch_time_circle].to_i
      @trade_source.high_pressure_valve = params[:trade_source][:high_pressure_valve]

      @trade_source.save
      redirect_to trade_source_path(@trade_source)
   end
end