# -*- encoding : utf-8 -*-
class JingdongAppTokensController < ApplicationController
  #skip_before_filter :authenticate_user!
  #目前只考虑到已经创建了Account的帐户
  def index
    info = auth_hash.info
    parameters = {access_token: info.token,refresh_token: info.refresh_token,jingdong_user_id: info.uid,account_id: current_account.id}

    trade_source = current_account.jingdong_sources.where(name: info.user_nick).first_or_create

    (trade_source.jingdong_app_token || trade_source.build_jingdong_app_token).update_attributes!(parameters)

    JingdongInitialFetcher.perform_async(trade_source.id)
    redirect_to root_path(notice: "#{info.user_nick}添加成功,正在抓取订单数据")
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end