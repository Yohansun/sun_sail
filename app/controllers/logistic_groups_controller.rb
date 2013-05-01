# encoding: utf-8
class LogisticGroupsController < ApplicationController
  before_filter :fetch_group, only: [:destroy]

  def index
    @groups = current_account.logistic_groups
  end

  def create
    @group = LogisticGroup.new(params[:logistic_group])
    @group.account = current_account
    if @group.save
      flash[:notice] = '物流分组创建成功'
    else
      flash[:alert] = '物流分组创建失败'
    end
    redirect_to logistic_groups_path
  end

  def destroy
    @group.destroy
    flash[:notice] = '物流分组删除成功'
    redirect_to logistic_groups_path
  end

  private
  def fetch_group
    @group = LogisticGroup.find(params[:id])
  end
end
