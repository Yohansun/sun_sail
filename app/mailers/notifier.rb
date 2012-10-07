# -*- encoding : utf-8 -*-
class Notifier < ActionMailer::Base
  helper :application
  default :from => "E-Business@nipponpaint.com.cn"
  
  def app_token_errors(token,response)
    mail(:to => %w{errors@networking.io},
         :subject => "淘宝app token授权失败",
         :body => "淘宝app token: 
                   #{token.to_yaml} 
                   错误代码: 
                   #{response['error_description']}",
         :reply_to => 'E-Business@nipponpaint.com.cn')
  end  

  def dispatch(id, notify_kind)
    object = Trade.find id
    @notify_kind = notify_kind
    @trade = TradeDecorator.decorate(object)
    @tid = @trade.tid
    @trade_from = @trade.trade_source
    @area_name = ' '
    if @trade.receiver_state
      @area_name += @trade.receiver_state
    end
    if @trade.receiver_city
      @area_name += @trade.receiver_city
    end
    if @trade.receiver_district
      @area_name += @trade.receiver_district
    end
    if @trade.receiver_address
      @area_full_name = @area_name + @trade.receiver_address
    else 
      @area_full_name = @area_name  
    end

    @is_1568 = @trade.is_1568
    @trade_info = "您好，#{@area_name}地区目前有一张#{@trade_from}订单"
    mail_subject = "#{@trade_from}订单#{@tid}-#{@area_name}（#{Time.now.strftime("%Y/%m/%d")}），请及时发货"
    reply_to = 'E-Business@nipponpaint.com.cn'
    bcc = %w(ayaya8586@163.com)

    if @trade.seller
      to_emails = @trade.seller.parent.email.split(',')
      cc_emails = @trade.cc_emails
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

