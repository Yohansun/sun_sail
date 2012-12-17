# -*- encoding : utf-8 -*-
class WangwangDataReprocess
  include Sidekiq::Worker
  sidekiq_options :queue => :data_process
  
  def perform()
    start_date = (Time.now - 20.days).beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")
    p start_date
    end_date = (Time.now - 20.days).end_of_day.strftime("%Y-%m-%d %H:%M:%S")
    p end_date
    WangwangPuller.new.get_wangwang_data(start_date, end_date)
    p "start member_brief_info"
    member_brief_info(start_date.to_time, end_date.to_time)
  end

  def member_brief_info(start_date, end_date)
    WangwangChatlog.all.each do |log|
      p "chatlog_filter"
      log.chatlog_filter
    end
    today = start_date.to_i
    yesterday = start_date.yesterday.to_i
    inquired_today = WangwangChatpeer.where(date: today).map(&:buyer_nick).uniq
    inquired_today_yesterday = WangwangChatpeer.where(:date.in => [today, yesterday]).map(&:buyer_nick).uniq
    WangwangMember.all.each do |m|
      #当日接待
      daily_reply_count = WangwangReplyState.where(user_id: m.service_staff_id).where(reply_date: today).sum(:reply_num) || 0

      #当日询单（该数据须延迟一天统计)
      daily_inquired_count = WangwangChatpeer.where(user_id: m.service_staff_id).where(date: today).map(&:buyer_nick).count

      #下单订单: 前一日或当日询单，本旺旺落实当日下单订单
      yesterday_created_count = 0
      yesterday_created_payment = 0
      yesterday_created_trades = TaobaoTrade.where(:buyer_nick.in => inquired_today_yesterday).where(:created.gte => start_date, :created.lt => end_date)
      yesterday_created_trades.each do |trade|
        WangwangChatlog.where(user_id: m.service_staff_id).each do |log|
          if (log.start_time..log.end_time).include?(trade.created)
              yesterday_created_count += 1
              yesterday_created_payment += trade.payment
          end
        end
        clert_chatlog = WangwangChatlog.where(:end_time.lt => trade.created).where(buyer_nick: trade.buyer_nick)
        if clert_chatlog.count == 1 && m.service_staff_id == clert_chatlog.first.user_id
          yesterday_created_count += 1
          yesterday_created_payment += trade.payment
        elsif clert_chatlog.count > 1
          min_gap = 172800  #two_day
          user_id = ''
          clert_chatlog.each do |log|
            if min_gap > trade.created - log.end_time
              user_id = log.user_id
              min_gap = trade.created - log.end_time
            end
          end
          if m.service_staff_id == user_id
            yesterday_created_count += 1
            yesterday_created_payment += trade.payment
          end
        end
      end

      #下单订单: 当日询单，本旺旺落实当日下单订单
      daily_created_trades = TaobaoTrade.where(:buyer_nick.in => inquired_today).where(:created.gte => start_date, :created.lt => end_date)
      result = chatlog_query(daily_created_trades, m.service_staff_id, "created")
      daily_created_count = result.count
      daily_created_payment = result.try(:sum, :payment) || 0

      #当日询单，当日次日下单人数
      tomorrow_created_trades = TaobaoTrade.where(:buyer_nick.in => inquired_today).where(:created.gte => start_date, :created.lt => (end_date + 1.day))
      result = chatlog_query(tomorrow_created_trades, m.service_staff_id, "created")
      tomorrow_created_count = result.count
      tomorrow_created_payment= result.try(:sum, :payment) || 0

      #当日询单，当日次日均未下单（延迟一天统计）
      tomorrow_lost_count = daily_inquired_count - tomorrow_created_count

      #前一日或当日询单，本旺旺落实当日下单后最终未付款
      yesterday_lost_trades = TaobaoTrade.where(:buyer_nick.in => inquired_today_yesterday).where(:created.gte => start_date, :created.lt => end_date).where(pay_time: nil)
      result = chatlog_query(yesterday_lost_trades, m.service_staff_id, "created")
      yesterday_lost_count = result.count
      yesterday_lost_payment = result.try(:sum, :payment) || 0

      #前一日或当日询单，本旺旺落实当日下单当日付款
      yesterday_paid_trades = TaobaoTrade.where(:buyer_nick.in => inquired_today_yesterday).where(:created.gte => start_date, :created.lt => end_date).where(:pay_time.gte => start_date, :pay_time.lt => end_date)
      result = chatlog_query(yesterday_paid_trades, m.service_staff_id, "created")
      second_result = chatlog_query(result, m.service_staff_id, "pay_time")
      yesterday_paid_count = second_result.count
      yesterday_paid_payment = second_result.count

      #前一日或当日询单，本旺旺落实当日下单后最终付款
      yesterday_final_paid_trades = TaobaoTrade.where(:buyer_nick.in => inquired_today_yesterday).where(:created.gte => start_date, :created.lt => end_date).where(:pay_time.ne => nil)
      result = chatlog_query(yesterday_final_paid_trades, m.service_staff_id, "created")
      yesterday_final_paid_count = result.count
      yesterday_final_paid_payment = result.try(:sum, :payment) || 0

      ## 落实付款 ##
      #付款订单: 本旺旺落实当日付款订单
      daily_paid_trades = TaobaoTrade.where(:pay_time.gte => start_date, :pay_time.lt => end_date)
      result = chatlog_query(daily_paid_trades, m.service_staff_id, "pay_time")
      daily_paid_count = result.count
      daily_paid_payment = result.try(:sum, :payment) || 0
      #本人单
      second_result = chatlog_query(result, m.service_staff_id, "created")
      daily_self_paid_count = second_result.count
      daily_self_paid_payment = second_result.try(:sum, :payment) || 0
      #静默单
      daily_quiet_paid_count = 0
      daily_quiet_paid_payment = 0
      second_result.each do |trade|
        chatlog_count = WangwangChatlog.where(:end_time.lt => trade.created).where(buyer_nick: trade.buyer_nick).count
        if chatlog_count == 0
          daily_quiet_paid_count += 1
          daily_quiet_paid_payment += trade.payment
        end
      end
      #他人单
      daily_others_paid_count = daily_paid_count - daily_self_paid_count - daily_quiet_paid_count
      daily_others_paid_payment = daily_paid_payment - daily_self_paid_payment - daily_quiet_paid_payment

      WangwangMemberContrast.create(
          user_id:                       m.short_id,
          created_at:                    start_date,
          daily_reply_count:             daily_reply_count,
          daily_inquired_count:          daily_inquired_count,
          yesterday_created_count:       yesterday_created_count,
          yesterday_created_payment:     yesterday_created_payment,
          daily_paid_count:              daily_paid_count,
          daily_paid_payment:            daily_paid_payment,
          daily_created_count:           daily_created_count,
          daily_created_payment:         daily_created_payment,
          tomorrow_lost_count:           tomorrow_lost_count,
          tomorrow_created_count:        tomorrow_created_count,
          tomorrow_created_payment:      tomorrow_created_payment,
          yesterday_lost_count:          yesterday_lost_count,
          yesterday_lost_payment:        yesterday_lost_payment,
          yesterday_paid_count:          yesterday_paid_count,
          yesterday_paid_payment:        yesterday_paid_payment,
          yesterday_final_paid_count:    yesterday_final_paid_count,
          yesterday_final_paid_payment:  yesterday_final_paid_payment,
          daily_quiet_paid_count:        daily_quiet_paid_count,
          daily_quiet_paid_payment:      daily_quiet_paid_payment,
          daily_self_paid_count:         daily_self_paid_count,
          daily_self_paid_payment:       daily_self_paid_payment,
          daily_others_paid_count:       daily_others_paid_count,
          daily_others_paid_payment:     daily_others_paid_payment)
    end
  end

  def chatlog_query(trades, user_id, time_status)
    tids = []
    trades.each do |trade|
      WangwangChatlog.where(user_id: user_id).each do |log|
        if (log.start_time..log.end_time).include?(trade[time_status])
           tids << trade.tid
        end
      end
      clert_chatlog = WangwangChatlog.where(:end_time.gte => (trade[time_status] - 2.day), :end_time.lt => trade[time_status]).where(buyer_nick: trade.buyer_nick)
      if clert_chatlog.count == 1 && user_id == clert_chatlog.first.user_id
        tids << trade.tid
      elsif clert_chatlog.count > 1
        min_gap = 172800  #two_day
        id = ''
        clert_chatlog.each do |log|
          if min_gap > trade[time_status] - log.end_time
            id = log.user_id
            min_gap = trade[time_status] - log.end_time
          end
        end
        if user_id == id
          tids << trade.tid
        end
      end
    end
    trades.where(:tid.in => tids)
  end
end