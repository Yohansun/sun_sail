# -*- encoding : utf-8 -*-
class TaobaoAppTokensController < ApplicationController
  skip_before_filter :authenticate_user!
  def create
    Account.transaction do
      TradeSource.transaction do
        TaobaoAppToken.transaction do

          info = auth_hash['info']
          account = current_account || Account.where(name: info['taobao_user_nick'],key: info.taobao_user_id).first_or_create!
          trade_source = TradeSource.where(account_id: account.id,name: info['taobao_user_nick'],trade_type: "Taobao").first_or_create!
          trade_source.taobao_app_token ||
          trade_source.create_taobao_app_token!({
            account_id:       account.id,
            taobao_user_id:   info['taobao_user_id'],
            taobao_user_nick: info['taobao_user_nick'],
            access_token:     auth_hash["credentials"]["token"],
            refresh_token:    auth_hash["credentials"]["refresh_token"]
          })
          session[:account_id] = account.id

          response = TaobaoQuery.get({method: 'taobao.shop.get', fields: 'sid,cid,title,nick,desc,bulletin,created,modified', nick: "#{info['taobao_user_nick']}" }, trade_source.id )
          if response['shop_get_response']
            source = response["shop_get_response"]["shop"]
            if source
              source["description"] = source.delete("desc")
              source["name"] = source.delete("nick")
              trade_source.update_attributes!(source)
            end

            MagicOneHitFetcher.perform_async(trade_source.id)

            if not trade_source.settings.one_hit_fetcher_started
              trade_source.settings.one_hit_fetcher_started = true
              redirect_to(account_setups_path)
            else
              redirect_to(root_path)
            end

          else
            render text: "response_get_failed : #{response.inspect}"
          end
        end
      end
    end
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
