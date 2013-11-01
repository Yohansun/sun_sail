# -*- encoding : utf-8 -*-
class WangwangDataReprocess
  include Sidekiq::Worker
  sidekiq_options :queue => :wangwang_data_reprocess, unique: true, unique_job_expiration: 120

  def perform(start_date = nil, end_date = nil)
    start_date ||= (Time.now - 1.day).to_date
    end_date ||= (Time.now - 1.day).to_date
    if WangwangReplyState.all.map(&:reply_date).include?(start_date.to_s.to_time.to_i)
#      p "delete_all"
      WangwangMemberContrast.delete_all
    end
    (start_date..end_date).each do |day|
      start_time = (day.to_time - 1.day).beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")
      end_time = (day.to_time - 1.day).end_of_day.strftime("%Y-%m-%d %H:%M:%S")
      WangwangPuller.new.get_wangwang_data(start_time, end_time)
      start_time = day.to_time.beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")
      end_time = day.to_time.end_of_day.strftime("%Y-%m-%d %H:%M:%S")
#      p "start member_brief_info"
      WangwangPuller.new.get_wangwang_data(start_time, end_time)
      member_brief_info(start_time.to_time, end_time.to_time)
    end
  end

  def member_brief_info(start_date, end_date)
    start_time = start_date - 8.hours
    end_time = end_date - 8.hours
#    p "chatlog_filter"
    WangwangChatlog.where(special_log: true).each do |log|
      log.chatlog_filter
    end
    chatlogs = WangwangChatlog.where(usable: true)
    today = start_date.to_i
    yesterday = start_date.yesterday.to_i
    inquired_today = WangwangChatpeer.where(date: today).map(&:buyer_nick).uniq
    inquired_today_yesterday = WangwangChatpeer.where(:date.in => [today, yesterday]).map(&:buyer_nick).uniq

#    p "start_reprocessing"
    yesterday_created_trades = TaobaoTrade.where(:buyer_nick.in => inquired_today_yesterday).where(:created.gte => start_time, :created.lt => end_time)
    daily_created_trades = TaobaoTrade.where(:buyer_nick.in => inquired_today).where(:created.gte => start_time, :created.lt => end_time)
    tomorrow_created_trades = TaobaoTrade.where(:buyer_nick.in => inquired_today).where(:created.gte => start_time, :created.lt => (end_date + 1.day))
    yesterday_lost_trades = TaobaoTrade.where(:buyer_nick.in => inquired_today_yesterday).where(:created.gte => start_time, :created.lt => end_time).where(pay_time: nil)
    yesterday_paid_trades = TaobaoTrade.where(:buyer_nick.in => inquired_today_yesterday).where(:created.gte => start_time, :created.lt => end_time).where(:pay_time.gte => start_time, :pay_time.lt => end_time)
    yesterday_final_paid_trades = TaobaoTrade.where(:buyer_nick.in => inquired_today_yesterday).where(:created.gte => start_time, :created.lt => end_time).where(:pay_time.ne => nil)
    daily_paid_trades = TaobaoTrade.where(:pay_time.gte => start_time, :pay_time.lt => end_time)

    WangwangMember.all.each_with_index do |m, i|
#      p i
#      p m.user_id
      # next if m.user_id != "立邦漆官方旗舰店:千色"
      #当日接待
      daily_reply_count = WangwangReplyState.where(user_id: m.service_staff_id).where(reply_date: today).sum(:reply_num) || 0

      #当日询单（该数据须延迟一天统计)
      daily_inquired_count = chatlogs.where(date: today).where(user_id: m.service_staff_id).map(&:buyer_nick).to_a.uniq.count
      #daily_inquired_count = WangwangChatpeer.where(user_id: m.service_staff_id).where(date: today).map(&:buyer_nick).uniq.count

      #下单订单: 前一日或当日询单，本旺旺落实当日下单订单
      result = chatlog_query(yesterday_created_trades, m.service_staff_id, "created")
      yesterday_created_count = result.map(&:buyer_nick).to_a.uniq.count
      yesterday_created_payment = result.try(:sum, :payment) || 0
      # if m.user_id == "立邦漆官方旗舰店:千色"
      #   p "@@@@@@@@@@@@@@@@@@@@@@@@"
      #   p result.map(&:tid)
      # end

      #下单订单: 当日询单，本旺旺落实当日下单订单
      result = chatlog_query(daily_created_trades, m.service_staff_id, "created")
      daily_created_count = result.map(&:buyer_nick).to_a.uniq.count
      daily_created_payment = result.try(:sum, :payment) || 0

      #当日询单，当日次日下单人数
      result = chatlog_query(tomorrow_created_trades, m.service_staff_id, "created")
      tomorrow_created_count = result.map(&:buyer_nick).to_a.uniq.count
      tomorrow_created_payment = result.try(:sum, :payment) || 0

      #当日询单，当日次日均未下单（延迟一天统计）
      tomorrow_lost_count = daily_inquired_count - tomorrow_created_count

      #前一日或当日询单，本旺旺落实当日下单后最终未付款
      result = chatlog_query(yesterday_lost_trades, m.service_staff_id, "created")
      yesterday_lost_count = result.map(&:buyer_nick).to_a.uniq.count
      yesterday_lost_payment = result.try(:sum, :payment) || 0

      #前一日或当日询单，本旺旺落实当日下单当日付款
      result = chatlog_query(yesterday_paid_trades, m.service_staff_id, "created")
      second_result = chatlog_query(result, m.service_staff_id, "pay_time")
      yesterday_paid_count = second_result.map(&:buyer_nick).to_a.uniq.count
      yesterday_paid_payment = second_result.try(:sum, :payment) || 0

      #前一日或当日询单，本旺旺落实当日下单后最终付款
      result = chatlog_query(yesterday_final_paid_trades, m.service_staff_id, "created")
      yesterday_final_paid_count = result.map(&:buyer_nick).to_a.uniq.count
      yesterday_final_paid_payment = result.try(:sum, :payment) || 0

      ## 落实付款 ##
      #付款订单: 本旺旺落实当日付款订单
      result = chatlog_query(daily_paid_trades, m.service_staff_id, "pay_time")
      daily_paid_count = result.map(&:buyer_nick).to_a.uniq.count
      daily_paid_payment = result.try(:sum, :payment) || 0
      #本人单
      second_result = chatlog_query(result, m.service_staff_id, "created")
      daily_self_paid_count = second_result.map(&:buyer_nick).to_a.uniq.count
      daily_self_paid_payment = second_result.try(:sum, :payment) || 0

      #静默单
      daily_quiet_paid_count = 0
      daily_quiet_paid_payment = 0
      quiet_buyer = []
      result.each do |trade|
        chatlog_count_1 = chatlogs.where(:end_time.lt => trade.created).where(buyer_nick: trade.buyer_nick).count
        chatlog_count_2 = chatlogs.where(:start_time.lte => trade.created, :end_time.gt => trade.created).where(buyer_nick: trade.buyer_nick).count
        if (chatlog_count_1 + chatlog_count_2) == 0
          quiet_buyer << trade.buyer_nick
          daily_quiet_paid_payment += trade.payment
        end
      end
      daily_quiet_paid_count = quiet_buyer.uniq.count
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
#    p "process_end"
  end

  def chatlog_query(trades, user_id, time_status)
    tids = []
    chatlogs = WangwangChatlog.where(usable: true)
    trades.each do |trade|

      #在谈话中动作
      clert_chatlog = chatlogs.where(buyer_nick: trade.buyer_nick).where(:start_time.lte => trade[time_status], :end_time.gt => trade[time_status])
      if clert_chatlog.count == 1 && user_id == clert_chatlog.first.user_id
#        p trade[time_status]
        tids << trade.tid
#        p "^^^^^^^^^^^^^^^^^^^"
#        p trade.tid
      elsif clert_chatlog.count > 1
        max_time = 0
        id = ''
        clert_chatlog.each do |log|
          if max_time < log.end_time.to_i
            id = log.user_id
            max_time = log.end_time.to_i
          end
        end
        if user_id == id
#          p trade[time_status]
          tids << trade.tid
#          p "%%%%%%%%%%%%%%%%%%%%%"
#          p trade.tid
        end
      end

      #在谈话后动作
      clert_chatlog = chatlogs.where(buyer_nick: trade.buyer_nick)
      flag = false
      clert_chatlog.each{|log| flag = true if log.start_time.to_i <= trade[time_status].to_i && log.end_time.to_i >= trade[time_status].to_i}
      if flag
        next
      else
        clert_chatlog = chatlogs.where(buyer_nick: trade.buyer_nick).where(:end_time.gte => (trade[time_status] - 2.days), :end_time.lt => trade[time_status])
        if clert_chatlog.count == 1 && user_id == clert_chatlog.first.user_id
          tids << trade.tid
#          p clert_chatlog.first.start_time
#          p clert_chatlog.first.end_time
#          p trade[time_status]
#          p "~~~~~~~~~~~~~~~~~~~~~~~"
#          p trade.tid
        elsif clert_chatlog.count > 1
          min_gap = 172800  #two days
          id = ''
          clert_chatlog.each do |log|
            if min_gap > (trade[time_status].to_i - log.end_time.to_i)
              id = log.user_id
              min_gap = trade[time_status].to_i - log.end_time.to_i
            end
          end
          if user_id == id
            tids << trade.tid
#            p "!!!!!!!!!!!!!!!!!!!!!!"
#            p trade.tid
          end
        end
      end
    end
    TaobaoTrade.where(:tid.in => tids)
  end
end