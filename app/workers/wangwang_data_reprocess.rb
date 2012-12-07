# -*- encoding : utf-8 -*-
class WangwangDataReprocess
  include Sidekiq::Worker
  sidekiq_options :queue => :data_process
  
  def perform()
    start_date = (Time.now - 14.days).beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")
    p start_date
    end_date = (Time.now - 14.days).end_of_day.strftime("%Y-%m-%d %H:%M:%S")
    p end_date
    WangwangPuller.get_wangwang_data(start_date, end_date)
    p "start member_brief_info"
    member_brief_info(start_date.to_time, end_date.to_time)
  end

  def member_brief_info(start_date, end_date)
    @members = WangwangMember.all
    @members.each do |m|
      inquired_today = WangwangChatpeer.where(user_id: m.service_staff_id).where(:date.gte => start_date, :date.lt => end_date).map(&:buyer_nick)
      inquired_today_and_yesterday = WangwangChatpeer.where(user_id: m.service_staff_id).where(:date.gte => (start_date - 1.day), :date.lt => end_date).map(&:buyer_nick)

      #当日接待
      daily_reply_count = WangwangReplyState.where(user_id: m.service_staff_id).where(:reply_date.gte => start_date, :reply_date.lt => end_date).sum(:reply_num) || 0

      #当日询单（该数据须延迟一天统计)
      daily_inquired_count = WangwangChatpeer.where(user_id: m.service_staff_id).where(:date.gte => start_date, :date.lt => end_date).map(&:buyer_nick).count

      #下单订单: 前一日或当日询单，本旺旺落实当日下单订单
      created_trades = TaobaoTrade.only(:buyer_nick, :created, :payment).where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => inquired_today_and_yesterday)

      #下单人数
      daily_created_count = created_trades.try(:map, &:buyer_nick).uniq.count

      #下单金额
      daily_created_payment = created_trades.try(:sum, :payment) || 0

      #付款订单: 本旺旺落实当日付款订单
      paid_trades = TaobaoTrade.only(:buyer_nick, :pay_time, :payment).where(:pay_time.gte => start_date, :pay_time.lt => end_date).where(:buyer_nick.in => inquired_today)

      #付款人数
      daily_paid_count = paid_trades.try(:map, &:buyer_nick).uniq.count

      #付款金额
      daily_paid_payment = paid_trades.try(:sum, :payment) || 0

      WangwangMemberContrast.create(user_id: m.short_id, created_at: start_date, daily_reply_count: daily_reply_count, daily_inquired_count: daily_inquired_count, daily_created_count: daily_created_count, daily_created_payment: daily_created_payment, daily_paid_count: daily_paid_count, daily_paid_payment: daily_paid_payment)
    end
  end
  
end