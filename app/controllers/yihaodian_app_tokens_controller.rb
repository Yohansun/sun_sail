# -*- encoding : utf-8 -*-
class YihaodianAppTokensController < ApplicationController
  #skip_before_filter :authenticate_user!
  #目前只考虑到已经创建了Account的帐户
  def index
    trade_source = TradeSource.where(trade_type: "Yihaodian", account_id: current_account.id).first
    if trade_source.blank?
      trade_source = TradeSource.create(trade_type: "Yihaodian",
                                        app_key: TradeSetting.yihaodian_app_key,
                                        secret_key: TradeSetting.yihaodian_app_secret,
                                        account_id: current_account.id,
                                        name: "一号店"+current_account.name)
    end

    token = YihaodianAppToken.where(trade_source_id: trade_source.id).first
    unless token.present?
      YihaodianAppToken.create(account_id: current_account.id,
                               trade_source_id: trade_source.id,
                               yihaodian_user_id: auth_hash.info.user_id,
                               yihaodian_user_nick: auth_hash.info.nick_name,
                               access_token: auth_hash.info.access_token,
                               isv_id: auth_hash.info.isv_id,
                               merchant_id: auth_hash.info.merchant_id,
                               user_code: auth_hash.info.user_code,
                               user_type: auth_hash.info.user_type)
      YihaodianInitialFetcher.perform_async(current_account.id)
      render text: "一号店Token已添加,正在抓取订单数据"
    else
      render text: "Token已添加过"
    end
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end