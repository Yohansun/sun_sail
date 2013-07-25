# -*- encoding : utf-8 -*-
class TaobaoAppTokensController < ApplicationController
  skip_before_filter :authenticate_user!
  def create
    info = auth_hash['info']
    token = TaobaoAppToken.where(taobao_user_id: info['taobao_user_id']).first
    unless token
      token = TaobaoAppToken.create(taobao_user_id: info['taobao_user_id'], taobao_user_nick: info['taobao_user_nick'], access_token: auth_hash["credentials"]["token"], refresh_token: auth_hash["credentials"]["refresh_token"])
    end
    trade_source = TradeSource.where(name: info['taobao_user_nick']).first_or_create
    trade_source_id = trade_source.id
    account = Account.where(name: info['taobao_user_nick']).first_or_create
    account.update_attributes(key: info['taobao_user_id']) if account.key.blank?
    session[:account_id] = account.id
    token.update_attributes(trade_source_id: trade_source_id, account_id: account.id)
    trade_source.update_attributes(account_id: account.id)
    response = TaobaoQuery.get({method: 'taobao.shop.get', fields: 'sid,cid,title,nick,desc,bulletin,created,modified', nick: "#{info['taobao_user_nick']}" }, trade_source_id )
    if response['shop_get_response']
      source = response["shop_get_response"]["shop"]
      if source
        source["description"] = source.delete("desc")
        source["name"] = source.delete("nick")
        trade_source.update_attributes(source)
      end
      unless account.settings.one_hit_fetcher_started
        account.settings.one_hit_fetcher_started = true
        MagicOneHitFetcher.perform_async(account.id)
      end
      redirect_to account_setups_path
    else
      render text: "response_get_failed : #{response.inspect}"
    end
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
