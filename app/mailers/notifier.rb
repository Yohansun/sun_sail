# -*- encoding : utf-8 -*-
class Notifier < ActionMailer::Base
  helper :application
  default :from => TradeSetting.email_notifier_from
  
  def app_token_errors(token,response)
    mail(:to => %w{errors@networking.io},
         :subject => "淘宝app token授权失败",
         :body => "淘宝app token: 
                   #{token.to_yaml} 
                   错误代码: 
                   #{response['error_description']}"
        )
  end  

  def dispatch(id, notify_kind)
    
    object = Trade.find id
    @trade = TradeDecorator.decorate(object)

    if @trade.seller
      
      seller = @trade.seller
      @notify_kind = notify_kind
      @tid = @trade.tid
      @trade_from = @trade.trade_source
      
      if TradeSetting.company == "dulux"
        @area_name = @trade.receiver_area_name
        to_emails = @trade.seller.email.split(',')
        cc_emails = []
      else  
        @area_name = seller.interface_name
        to_emails = @trade.seller.parent.email.split(',')
        cc_emails = @trade.cc_emails
      end 
    
      @area_full_name = @trade.receiver_full_address

      @is_1568 = @trade.is_1568
      @trade_info = "您好，#{@area_name}地区目前有一张#{@trade_from}订单"
      mail_subject = "#{@trade_from}订单#{@tid}-#{@area_name}（#{Time.now.strftime("%Y/%m/%d")}），请及时发货"
      reply_to = TradeSetting.email_notifier_from
      bcc = %w(TradeSetting.email_notifier_dispatch_bcc)  
    
      to_emails.each_with_index do |email, index|
        if index == 0
          mail(:to => email,
               :cc => cc_emails,
               :bcc => bcc,
               :subject => mail_subject,
               :reply_to => reply_to
          )
        else
          mail(:to => email,
               :subject => mail_subject,
               :bcc => bcc,
               :reply_to => reply_to
          )
        end
      end
    end
  end
end

