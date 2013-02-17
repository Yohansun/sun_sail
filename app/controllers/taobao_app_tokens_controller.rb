class TaobaoAppTokensController < ApplicationController

  # Remember to create and bind account first.
  def create
    info = auth_hash['info']
    token = TaobaoAppToken.find_or_create_by_taobao_user_id(info['taobao_user_id'])
    token.taobao_user_nick = info['taobao_user_nick']
    token.access_token = auth_hash["credentials"]["token"]
    token.refresh_token = auth_hash["credentials"]["refresh_token"]
    token.save

    trade_source = TradeSource.find_or_create_by_name(info['taobao_user_nick'])
    token.update_attributes(trade_source_id: trade_source.id) ## need optimize
    response = TaobaoQuery.get({method: 'taobao.shop.get',
                                fields: 'sid,cid,title,nick,desc,bulletin,created,modified',
                                nick: "#{token.taobao_user_nick}" },
                                trade_source.id
                              )

    if response['shop_get_response']
      source = response["shop_get_response"]["shop"]
      source["account_id"] = token.account_id
      source["description"] = source.delete("desc")
      source["name"] = source.delete("nick")
      trade_source.update_attributes(source)

      TradeSetting.enable_token_error_notify = true
      redirect_to root_path
    else
      render text: "response_get_failed"
    end

  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end