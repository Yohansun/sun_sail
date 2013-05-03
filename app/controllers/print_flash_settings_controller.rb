# -*- encoding : utf-8 -*-
class PrintFlashSettingsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :authenticate_user!
  before_filter :admin_only!
  before_filter :fetch_setting, only: [:show, :print_infos, :update_infos]

  def show
  end

  def print_infos
    respond_to do |format|
      format.xml
    end
  end

  def info_list
    respond_to do |format|
      format.xml
    end
  end

  def update_infos
    @setting.update_attributes(xml_hash: JSON.parse(params[:data]))
    render text: "1"
  end

  private

  def fetch_setting
    @setting = PrintFlashSetting.find(params[:id])
    @logistic = Logistic.find(params[:logistic_id])
    # unless @setting.present?
    #   PrintFlashSetting.create(logistic_id: params[:logistic_id])
    # end
  end
end