# -*- encoding : utf-8 -*-
class SalesController < ApplicationController
  
  def index
  end

  def show
  	@sale = Sale.last
  end

  def new
  	@sale = Sale.new
  end

  def create
  	start_at = "#{params[:times][:start_date]} #{params[:times][:start_time]}".to_time(form = :local)
    end_at = "#{params[:times][:end_date]} #{params[:times][:end_time]}".to_time(form = :local)
  	@sale = Sale.create(name: params[:sale][:name], earn_guess: params[:sale][:earn_guess], start_at: start_at, end_at: end_at)
  	if @sale.save
      redirect_to "/sales/show"
    else
      render sales_new_path
    end
  end

end


