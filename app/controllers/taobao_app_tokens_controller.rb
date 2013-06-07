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
      MagicOneHitFetcher.perform_async(account.id)
      redirect_to account_setups_path
    else
      render text: "response_get_failed : #{response.inspect}"
    end
  end

  def test
  end
  protected
  def auth_hash
    # for development testing , you can access website entry by : http://127.0.0.1:3000/test_init
    if Rails.env == 'development'
      ({
        "bianbian415"=>{
          'info'=>{
            'taobao_user_id'=> "63785456", 
            'taobao_user_nick'=> "bianbian415"
          },
          'credentials'=>{
            'token'=>"6200d21e20df6cafe4d3717b71cb3ZZ7cb6c7f6ee2defdf63785456",
            'refresh_token'=>"6202421b7e1ad2c732cff2647d4d5ZZf7ea0458f96098d563785456",
          }
        },
        "xiaoliuchun"=>{
          'info'=>{
            'taobao_user_id'=> "24459833", 
            'taobao_user_nick'=> "xiaoliuchun"
          },
          'credentials'=>{
            'token'=>"6201405dc41dfhj8a2b2c2c4636cc65d56e4e0032dcc31624459833",
            'refresh_token'=>"6200e051d338ace6bf0948b5a68de35edfe4a87a0cf137d24459833"
          }
        }
      })[params[:user]]
    else
        request.env['omniauth.auth']
    end
  end
end
