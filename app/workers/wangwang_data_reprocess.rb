# -*- encoding : utf-8 -*-
class WangwangDataReprocess
  include Sidekiq::Worker
  sidekiq_options :queue => :data_process
  
  def perform()
    start_date = (Time.now - 17.days).beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")
    p start_date
    end_date = (Time.now - 17.days).end_of_day.strftime("%Y-%m-%d %H:%M:%S")
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
      daily_inquired_count = inquired_today.count

      #下单订单: 前一日或当日询单，本旺旺落实当日下单订单
      yesterday_created_trades = TaobaoTrade.where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => inquired_today_and_yesterday)
      yesterday_created_count = yesterday_created_trades.try(:map, &:buyer_nick).count
      yesterday_created_payment = yesterday_created_trades.try(:sum, :payment) || 0

      #付款订单: 本旺旺落实当日付款订单
      daily_paid_trades = TaobaoTrade.where(:pay_time.gte => start_date, :pay_time.lt => end_date).where(:buyer_nick.in => inquired_today)
      daily_paid_count = daily_paid_trades.try(:map, &:buyer_nick).count
      daily_paid_payment = daily_paid_trades.try(:sum, :payment) || 0

      #下单订单: 当日询单，本旺旺落实当日下单订单
      daily_created_trades = TaobaoTrade.where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => inquired_today)
      daily_created_count = daily_created_trades.try(:map, &:buyer_nick).count
      daily_created_payment = daily_created_trades.try(:sum, :payment) || 0

      #当日询单，当日次日下单人数
      tomorrow_created_count = TaobaoTrade.where(:created.gte => start_date, :created.lt => (end_date + 1.day)).where(:buyer_nick.in => inquired_today).map(&:buyer_nick).to_a.count
      #当日询单，当日次日下单金额
      tomorrow_created_payment = TaobaoTrade.where(:created.gte => start_date, :created.lt => (end_date + 1.day)).where(:buyer_nick.in => inquired_today).sum(:payment) || 0
      #当日询单，当日次日均未下单（延迟一天统计）
      tomorrow_lost_count = inquired_today.count - tomorrow_created_count

      WangwangMemberContrast.create(
        user_id:                     m.short_id,
        created_at:                  start_date,
        daily_reply_count:           daily_reply_count,
        daily_inquired_count:        daily_inquired_count,
        yesterday_created_count:     yesterday_created_count,
        yesterday_created_payment:   yesterday_created_payment,
        daily_paid_count:            daily_paid_count,
        daily_paid_payment:          daily_paid_payment,
        daily_created_count:         daily_created_count,
        daily_created_payment:       daily_created_payment,
        tomorrow_lost_count:         tomorrow_lost_count,
        tomorrow_created_count:      tomorrow_created_count,
        tomorrow_created_payment:    tomorrow_created_payment
        )
    end
  end
  
end