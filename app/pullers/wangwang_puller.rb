# -*- encoding : utf-8 -*-
class WangwangPuller

  START_DATE = (Time.now - 16.days).beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")
  END_DATE = (Time.now - 16.days).end_of_day.strftime("%Y-%m-%d %H:%M:%S")

  def get_wangwang_data(start_date = nil, end_date = nil, service_staff_ids = nil, manager_id = nil)
    unless WangwangReplyState.all.map(&:reply_date).include?(start_date.to_time.to_i)
      chatpeers_get(start_date, end_date, service_staff_ids) & receivenum_get(start_date, end_date, service_staff_ids) & chatlog_get(start_date, end_date, service_staff_ids) #
    end
  end

  private

  def chatpeers_get(start_date = nil, end_date = nil, service_staff_ids = nil)
#    p "start chatpeers_get"
    start_date ||= START_DATE
    end_date ||= END_DATE

    service_staff_ids ||= WangwangMember.all.map &:service_staff_id
    service_staff_ids.each_with_index do |chat_id, i|

      response = TaobaoFu.get(
        method: 'taobao.wangwang.eservice.chatpeers.get',
        chat_id: chat_id,
        start_date: start_date,
        end_date: end_date
      )
#      p response
#      p i

      if response['chatpeers_get_response'].present? && response['chatpeers_get_response']['ret'] = "10000"
        count = response['chatpeers_get_response']['count']
        if response['chatpeers_get_response']['chatpeers'].present? && response['chatpeers_get_response']['chatpeers']['chatpeer'].present?
          chatpeers = response['chatpeers_get_response']['chatpeers']['chatpeer']
          unless chatpeers.is_a?(Array)
            chatpeers = [] << chatpeers
          end
          chatpeers.each do |chatpeer|
            date = chatpeer['date'].to_time.to_i
            buyer_nick = chatpeer['uid'].gsub("cntaobao", "")
            WangwangChatpeer.create(user_id: chat_id, buyer_nick: buyer_nick, date: date)
          end
        end
      end
    end
  end 

  def chatlog_get(start_date = nil, end_date = nil,  service_staff_ids = nil)
#    p "start chatlog_get"
    start_date ||= START_DATE
    end_date ||= END_DATE
    from_ids ||= WangwangMember.all.map &:service_staff_id
    from_ids.each do |from_id|
      member = WangwangMember.find_with_service_staff_id(from_id)
      chatpeers = member.chatpeers(start_date, end_date)
      if chatpeers.present?   
        chatpeers.each_with_index do |to_id, i|
          to_id = "cntaobao" + to_id
          response = TaobaoFu.get(
            method: 'taobao.wangwang.eservice.chatlog.get',
            from_id: from_id,
            to_id: to_id,
            start_date: start_date,
            end_date: end_date
          )
#          p response
#          p i
          if response['chatlog_get_response'].present? && response['chatlog_get_response']['ret'] = "10000"
            count = response['chatlog_get_response']['count']
            if response['chatlog_get_response']['msgs'].present? && response['chatlog_get_response']['msgs']['msg'].present?
              msgs = response['chatlog_get_response']['msgs']['msg']
              chatlog = WangwangChatlog.create(
                  user_id: from_id,
                  buyer_nick: to_id.gsub("cntaobao",'')
              )
              unless msgs.is_a?(Array)
                msgs = [] << msgs
              end
              start_time = ""
              end_time = ""
              msgs.each_with_index do |msg, i|
                if i == 0
                  start_time = msg['time'].to_time(:local)
                end
                if i == msgs.count - 1
                  end_time = msg['time'].to_time(:local)
                end
                chatlog.wangwang_chatmsgs.build(
                  direction: msg['direction'],
                  time: msg['time'].to_time(:local),
                  content: msg['content']
                )
              end
              chatlog.update_attributes(date: start_time.to_date.to_s.to_time.to_i, start_time: start_time, end_time: end_time)
              chatlog.chatlog_filter
            end
            #sleep(2)
          end
        end
      end
    end  
  end
    
  # 服务提供时间（7:00:00-24:00:00）
  def receivenum_get(start_date = nil, end_date = nil, service_staff_ids = nil)
#    p "start receivenum_get"
    start_date ||= START_DATE
    end_date ||= END_DATE 

    service_staff_ids ||= WangwangMember.all.map &:service_staff_id

    service_staff_ids.each do |service_staff_id|

      response = TaobaoFu.get(
        method: 'taobao.wangwang.eservice.receivenum.get',
        service_staff_id: service_staff_id,
        start_date: start_date,
        end_date: end_date
      )
#      p response
      response = response['wangwang_eservice_receivenum_get_response']
      next unless response
      response = response['reply_stat_list_on_days']
      next unless response
      response = response['reply_stat_on_day']
      next unless response 
      unless response.is_a?(Array)
        response = [] << response
      end
      response.each do |rep|
        reply_date = rep['reply_date'].to_time.to_i
        reply_stat_by_ids = rep['reply_stat_by_ids']
        next unless reply_stat_by_ids
        reply_stat_by_ids = reply_stat_by_ids['reply_stat_by_id']   
        next unless reply_stat_by_ids 
        unless reply_stat_by_ids.is_a?(Array)
          reply_stat_by_ids = [] << reply_stat_by_ids
        end
        reply_stat_by_ids.each do |reply_stat_by_id|
          user_id = reply_stat_by_id['user_id']
          reply_num = reply_stat_by_id['reply_num']
          WangwangReplyState.create(user_id: reply_stat_by_id['user_id'],
                                    reply_num: reply_stat_by_id['reply_num'],
                                    reply_date: reply_date)
        end
      end
    end  
  end

end