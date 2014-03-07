# -*- encoding : utf-8 -*-
class YihaodianAppTokensController < ApplicationController
  #skip_before_filter :authenticate_user!
  #目前只考虑到已经创建了Account的帐户
  def index
    info = auth_hash.info

    trade_source = current_account.yihaodian_sources.where(name: info.nickName).first_or_create
    parameters = {
      account_id:           current_account.id,
      trade_source_id:      trade_source.id,
      yihaodian_user_id:    info.userId,
      yihaodian_user_nick:  info.nickName,
      access_token:         info.accessToken,
      isv_id:               info.isvId,
      merchant_id:          info.merchantId,
      user_code:            info.userCode,
      user_type:            info.userType
    }

    (trade_source.yihaodian_app_token || trade_source.build_yihaodian_app_token).update_attributes!(parameters)

    YihaodianInitialFetcher.perform_async(trade_source.id)
    redirect_to root_path(notice: "#{info.nick_name}添加成功,正在抓取订单数据")
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end