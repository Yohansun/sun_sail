# -*- encoding : utf-8 -*-
class TaobaoAppTokensController < ApplicationController

  def index
  end
  
  def create
    info = auth_hash['info']
    token = TaobaoAppToken.find_or_create_by_taobao_user_id(info['taobao_user_id'])
    token.taobao_user_nick = info['taobao_user_nick']
    token.access_token = auth_hash["credentials"]["token"]
    token.refresh_token = auth_hash["credentials"]["refresh_token"]
    token.save

    trade_source = TradeSource.create
    account = Account.create(name: "test", key: "test")  ## need optimize
    token.update_attributes(trade_source_id: trade_source.id)
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

      current_account.write_setting('enable_token_error_notify', true)
      MagicOneHitFetcher.perform(trade_source.id)
      redirect_to "/taobao_app_tokens"
    else
      render text: "response_get_failed"
    end

  end

  def create_admin
    @admin = User.create(email: params[:email], phone: params[:phone], password: "123456")
    if @admin.save
      @admin.add_role(:admin)
      ##TODO: should send email or sms
      render :js => "$('#start a[href=\"#autoset\"]').tab('show');"
    else
      render :js => "alert('输入信息无效，请重新输入');"
    end
  end
  
  def rolling_scrollbars
    render :js => "$('#start a[href=\"#autobusiness\"]').tab('show');"
  end

  def auto_settings
    TradeSetting.enable_auto_dispatch = params[:autodispatch].to_i
    TradeSetting.enable_auto_check = params[:autocheck].to_i
    TradeSetting.enable_auto_distribution = params[:autodistribution].to_i
    render :js => "$('#start a[href=\"#set_login_user\"]').tab('show');"
  end

  def create_roles
    cs = params[:cs]
    cs.each do |cs|
      ##TODO: regexp to distinguish between email and phone
      if email
        User.create(email: cs, password: "123456")
      else
        User.create(phone: cs, password: "123456")
      end
    end
    #TODO: below are the same as cs
    stock_admin = params[:stock_admin]
    interface = params[:inter_face]
    
    #TODO: should send email or sms
    redirect_to "/"
  end  

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end