# encoding: utf-8
class DeliverTemplatesController < ApplicationController
  layout "management"
  before_filter :authorize

  def index
    @templates = DeliverTemplate.all
    @default_template_id = current_account.deliver_template.id rescue nil
  end

  def new
    @template = DeliverTemplate.new
  end

  def create
    DeliverTemplate.create(params[:deliver_template])
    redirect_to deliver_templates_path
  end

  def edit
    @template = DeliverTemplate.find(params[:id])
  end

  def update
    @template = DeliverTemplate.find params[:id]
    @template.update_attributes params[:deliver_template]
    redirect_to deliver_templates_path
  end

  def change_default_template
    current_account.deliver_template = (DeliverTemplate.find params[:deliver_thumbnail] rescue nil)
    if current_account.deliver_template.present?
      flash[:notice] = '默认发货单模版设置成功'
    else
      flash[:notice] = '默认发货单模版设置失败,请重新选择'
    end
    redirect_to :back
  end
end