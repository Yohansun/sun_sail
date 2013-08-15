# -*- encoding : utf-8 -*-
class InitUserNotifier
  include Sidekiq::Worker
  sidekiq_options :queue => :init_user_notifier

  def perform(account_id, email, password, mobiles)
    account = Account.find_by_id(account_id)
    if mobiles
      sms = Sms.new(account, "Magic系统初始化用户提醒, 帐号: #{email}, 密码: #{password},请登陆后尽快修改密码", mobiles)
      sms.transmit
    end
    email = Notifier.init_user_notifications(email, password, account_id)
    email.deliver
  end

end