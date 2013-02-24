# -*- encoding : utf-8 -*-
class Notifier < ActionMailer::Base
  helper :application

  def app_token_errors(token,response, account_id)
    account = Account.find_by_id(account_id)
    mail(:to => %w{errors@networking.io},
         :subject => "#{account.key}淘宝app token授权失败",
         :body => "淘宝app token:#{token.to_yaml} \n 错误代码:#{response['error_description']}",
         :from => account.settings.email_notifier_from
        )
  end

  def manual_notify(mails, notify_content, notify_theme, account_id)
    account = Account.find_by_id(account_id)
    mail(:to => mails,
         :subject => notify_theme,
         :body => notify_content,
         :from => account.settings.email_notifier_from
        )
  end  

  def init_user_notifications(email, pwd, account_id)
    account = Account.find_by_id(account_id)
    mail(:to => email,
         :subject => 'Magic系统初始化用户提醒',
         :body => "帐号 #{email} 密码 #{pwd}",
         :from => account.settings.email_notifier_from
        )
  end

  def deliver_errors(id, errors, account_id)
    account = Account.find_by_id(account_id)
    mail(:to => %w{errors@networking.io},
         :subject => "#{account.key}发货异常提醒",
         :body => "订单ID: #{id}  \n 错误代码: #{errors} ",
         :from => account.settings.email_notifier_from
        )
  end

  def puller_errors(errors, account_id)
    account = Account.find_by_id(account_id)
    mail(:to => %w{errors@networking.io},
         :subject => "订单抓取异常提醒",
         :body => "错误代码: #{errors}",
         :from => account.settings.email_notifier_from
        )
  end

  def dispatch(id, seller_id, notify_kind)
    object = Trade.find id
    account_id = object.account_id
    @account = Account.find_by_id(account_id)
    seller = Seller.find seller_id
    @trade = TradeDecorator.decorate(object)

    if seller
      @notify_kind = notify_kind
      @tid = @trade.tid
      @trade_from = @trade.trade_source

      if @account.settings.enable_module_interface == 0
        @area_name = @trade.receiver_area_name
        to_emails = seller.email.try(:split, ',')
        cc_emails = []
        @trade_deliver_info = "请及时发货，谢谢。"
      else
        @area_name = seller.interface_name
        to_emails = seller.interface_email   
        to_emails = [] << to_emails unless to_emails.is_a?(Array)
        cc_emails = @trade.cc_emails
        @trade_deliver_info = "请及时通知经销商联系客户发货，并让其发货同时在“经销商后台”点击“确认发货”。之后请回复本邮件告知已发货。谢谢。"
        if @trade.is_1568
          @trade_deliver_info += "此订单为1568地区订单，请安排后续服务事宜。"
        end
      end

      @area_full_name = @trade.receiver_full_address
      @trade_info = "您好，#{@area_name}地区目前有一张#{@trade_from}订单"

      mail_subject = "#{@trade_from}订单#{@tid}-#{@area_name}（#{Time.now.strftime("%Y/%m/%d")}），请及时发货"
      reply_to = @account.settings.email_notifier_from
      bcc = @account.settings.email_notifier_dispatch_bcc
      
      mail(:to => to_emails, :cc => cc_emails, :bcc => bcc, :subject => mail_subject, :reply_to => reply_to, :from => @account.settings.email_notifier_from)  if to_emails.present?
   
    end
  end
end
