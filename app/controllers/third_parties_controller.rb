#encoding: utf-8
class ThirdPartiesController < ApplicationController
  before_filter :authorize

  def index
    @third_parties = default_scope
  end

  def edit
    @third_party = default_scope.find params[:id]
  end

  def show
    @third_party = default_scope.find params[:id]
  end

  def reset_token
    @third_party = default_scope.find params[:third_party_ids]
    Array.wrap(@third_party).each do |third_party|
      third_party.reset_authentication_token!
    end

    respond_to do |format|
      format.js
    end
  end

  def update
    @third_party = default_scope.find params[:id]
    if @third_party.update_attributes(params[:third_party])
      flash[:notice] = "更新成功"
      redirect_to action: :index
    else
      flash[:error] = "更新失败"
      render :edit
    end
  end

  def new
    @third_party = default_scope.new
  end

  def create
    third_party = params[:third_party].merge(user_id: current_user.id)
    @third_party = default_scope.new(third_party)
    @third_party.generate_token
    if @third_party.save
      flash[:notice] = "创建成功"
      redirect_to :action => :index
    else
      render :new
    end
  end

  private
  def default_scope
    ThirdParty.with_account(current_account.id)
  end
end