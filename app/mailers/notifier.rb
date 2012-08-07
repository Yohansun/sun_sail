# -*- encoding : utf-8 -*-
class Notifier < ActionMailer::Base
  helper :application
  default :from => "E-Business@nipponpaint.com.cn"

  def dispatch(id, notify_kind)
    object = Trade.find id
    @notify_kind = notify_kind
    @trade = TradeDecorator.decorate(object)
    @tid = @trade.tid
    @trade_from = @trade.trade_source
    @area_name = @trade.receiver_state + @trade.receiver_city + @trade.receiver_district

    @trade_info = "您好，#{@area_name}地区目前有一张#{@trade_from}订单"
    mail_subject = "#{@trade_from}订单#{@tid}-#{@area_name}（#{Time.now.strftime("%Y/%m/%d")}），请及时发货"
    reply_to = 'E-Business@nipponpaint.com.cn'
    #bcc = 'ayaya8586@163.com'

    if @trade.seller
      to_emails = %w(zhangjiyuan001@sina.com zhangjiyuan@networking.io) #@trade.seller.parent.email.split(',')
      cc_emails = %w(xiaoliang@networking.io) #@trade.cc_emails
      to_emails.each_with_index do |email, index|
        if index == 0
          mail(:to => email,
               :cc => cc_emails,
    #           :bcc => bcc,
               :subject => mail_subject,
               :reply_to => reply_to
          )
        else
          mail(:to => email,
               :subject => mail_subject,
    #           :bcc => bcc,
               :reply_to => reply_to
          )
        end
      end
    end
  end
end

