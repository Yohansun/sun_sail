class ColorsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :admin_only!, :except => [:autocomplete]
  before_filter :check_module, :except => [:autocomplete]

  def index
  	@colors = Color.page params[:page]
  end

  def edit
  	@color = Color.find params[:id]
  end

  def update
  	@color = Color.find params[:id]
  	if @color.update_attributes(params[:color])
  		redirect_to colors_path
  	else
  		render :edit
  	end
  end

  def new
  	@color = Color.new
  end

  def create
  	@color = Color.create(params[:color])
  	if @color.save
  		redirect_to colors_path
  	else
  		render :new
  	end
  end

  def destroy
    @color = Color.find params[:id]
    @color.destroy
    redirect_to colors_path
  end

  def autocomplete
    params[:num] = params[:num].gsub(/\W/, '') if params[:num].present?
    colors = Color.where("num LIKE '%#{params[:num]}%'")
    render json: colors.map { |c| c.num }
  end

  private

  def check_module
    redirect_to "/" and return if TradeSetting.enable_module_colors != true
    redirect_to "/" and return if !current_user.has_role?(:admin)
  end
end