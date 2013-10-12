#encoding: utf-8
class ThirdPartiesController < ApplicationController
  before_filter :authorize

  def index
    @third_parties = with_account
  end

  def reset_token
    @third_party = with_account.find params[:third_party_ids]
    Array.wrap(@third_party).each do |third_party|
      third_party.reset_authentication_token!
    end

    respond_to do |format|
      format.js
    end
  end

  def new
    @third_party = with_account.new
  end

  def create
    third_party = params[:third_party].merge(user_id: current_user.id)
    @third_party = with_account.new(third_party)
    @third_party.generate_token
    if @third_party.save
      flash[:notice] = "创建成功"
      redirect_to :action => :index
    else
      render :new
    end
  end

  private
  def with_account
    ThirdParty.with_account(current_account.id)
  end
end