# -*- encoding : utf-8 -*-
class JingdongAppTokensController < ApplicationController
  #skip_before_filter :authenticate_user!
  #目前只考虑到已经创建了Account的帐户
  def index
    auth_json = JSON.parse(auth_hash.to_json)
    trade_source = TradeSource.where(trade_type: "Jingdong", account_id: current_account.id).first
    if trade_source.blank?
      trade_source = TradeSource.create(trade_type: "Jingdong",
                                        app_key: TradeSetting.jingdong_app_key,
                                        secret_key: TradeSetting.jingdong_app_secret,
                                        account_id: current_account.id,
                                        name: "京东"+current_account.name)
    end

    token = JingdongAppToken.where(trade_source_id: trade_source.id).first
    if token.present?
      token.update_attributes(access_token: auth_json['credentials']['token'],
                              refresh_token: auth_json["credentials"]["refresh_token"])
      render text: '已重新生成京东Token'
    else
      JingdongAppToken.create(jingdong_user_id: auth_json['uid'],
                              access_token: auth_json['credentials']['token'],
                              refresh_token: auth_json["credentials"]["refresh_token"],
                              account_id: current_account.id,
                              trade_source_id: trade_source.id)
      JingdongInitialFetcher.perform_async(current_account.id)
      render text: "京东Token已添加,正在抓取订单数据"
    end
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end