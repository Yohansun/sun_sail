# -*- encoding : utf-8 -*-
class PrintFlashSettingsController < ApplicationController
  layout "management"

  skip_before_filter :verify_authenticity_token
  before_filter :authorize
  before_filter :authenticate_user!
  before_filter :fetch_setting, only: [:show, :print_infos, :update_infos, :update_xml_hash]

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

  def update_xml_hash
    xml_hash = JSON.parse(params[:print_flash_setting][:xml_hash].gsub(/\=>/, ':')) rescue ""
    if xml_hash.is_a?(Hash)
      @setting.update_attributes(xml_hash: xml_hash)
      render js: "alert('保存成功')"
    else
      render js: "alert('输入项不是合格的哈希值。')"
    end
  end

  private

  def fetch_setting
    @setting = PrintFlashSetting.find(params[:id])
    @logistic = Logistic.find(params[:logistic_id])
  end
end