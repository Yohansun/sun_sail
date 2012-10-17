class TaobaoAppTokensController < ApplicationController
  def create
    info = auth_hash['info']
    token = TaobaoAppToken.find_or_create_by_taobao_user_id(info['taobao_user_id'])
    token.taobao_user_nick = info['taobao_user_nick']
    token.access_token = auth_hash["credentials"]["token"]
    token.refresh_token = auth_hash["credentials"]["refresh_token"]
    token.save

    TradeSetting.enable_token_error_notify = true

    redirect_to root_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end