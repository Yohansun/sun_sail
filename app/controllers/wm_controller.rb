#encoding: utf-8
# wm = Warehouse Management 仓库管理
class WmController < ApplicationController
  layout "management"
  before_filter :authorize
  def show
  end

  def enable_third_party_stock
    current_account.settings.enable_module_third_party_stock = params[:enable].to_i.zero? ? 0 : 1
    redirect_to action: :show
  end
end
