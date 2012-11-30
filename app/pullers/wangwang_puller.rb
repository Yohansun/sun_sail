# -*- encoding : utf-8 -*-
class WangwangPuller

	START_DATE = (Time.now - 7.days).beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")
	END_DATE = Time.now.yesterday.end_of_day.strftime("%Y-%m-%d %H:%M:%S")

  def self.chatpeers_get(start_date = nil, end_date = nil, service_staff_ids = nil)
  	
    start_date ||= START_DATE
    end_date ||= END_DATE

    service_staff_ids ||= WangwangMember.all.map &:service_staff_id

    service_staff_ids.each do |chat_id|

      response = TaobaoFu.get(
        method: 'taobao.wangwang.eservice.chatpeers.get',
        chat_id: chat_id,
        start_date: start_date,
      	end_date: end_date
      )
      if response['chatpeers_get_response'].present? && response['chatpeers_get_response']['ret'] = "10000"
        count = response['chatpeers_get_response']['count']
        if response['chatpeers_get_response']['chatpeers'].present? && response['chatpeers_get_response']['chatpeers']['chatpeer'].present?
        	chatpeers = response['chatpeers_get_response']['chatpeers']['chatpeer']
          unless chatpeers.is_a?(Array)
            chatpeers = [] << chatpeers
          end 	
          chatpeers.each do |chatpeer|
        		uid = chatpeer['uid']
            date = chatpeer['date'].to_datetime
            WangwangChatpeer.create(user_id: chat_id, uid: uid, date:date)
          end	
        end  
      end

    end

  end	

  def self.chatlog_get(start_date = nil, end_date = nil,  service_staff_ids = nil)

    start_date ||= START_DATE
    end_date ||= END_DATE

    from_ids ||= WangwangMember.all.map &:service_staff_id

    from_ids.each do |from_id|
      member = WangwangMember.find_with_service_staff_id(from_id)
      chatpeers = member.chatpeers(start_date, end_date) 
      if chatpeers.present?   
        chatpeers.each do |to_id|         
          response = TaobaoFu.get(
            method: 'taobao.wangwang.eservice.chatlog.get',
            from_id: from_id,
            to_id: to_id,
            start_date: start_date,
          	end_date: end_date
          )
          if response['chatlog_get_response'].present? && response['chatlog_get_response']['ret'] = "10000"
            count = response['chatlog_get_response']['count']
            if response['chatlog_get_response']['msgs'].present? && response['chatlog_get_response']['msgs']['msg'].present?
            	msgs = response['chatlog_get_response']['msgs']['msg']
            	unless msgs.is_a?(Array)
                msgs = [] << msgs
              end 
              msgs.each do |msg|   	
              	WangwangChatlog.create(from_id: from_id, 
                 to_id: to_id, 
                 direction: msg['direction'], 
                 time: msg['time'].to_datetime,
                 content: msg['content']
                )
              end	
            end
            sleep(2)
          end  
        end    
      end
    end  
  end
  	
  # 服务提供时间（7:00:00-24:00:00）
  def self.receivenum_get(start_date = nil, end_date = nil, service_staff_ids = nil)
  	
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
      	reply_date = rep['reply_date']
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
            reply_date: reply_date.to_datetime
          )	
        end	  
      end  

    end  
  end

  # depreciate
  def self.groupmember_get(manager_id = nil)	
  	manager_id ||= TradeSetting.default_manager_id
  	response = TaobaoFu.get(
      method: 'taobao.wangwang.eservice.groupmember.get',
      manager_id: manager_id
    )
    p response
    if response['wangwang_eservice_groupmember_get_response'].present? && response['wangwang_eservice_groupmember_get_response']['group_member_list']
      group_member_list = response['wangwang_eservice_groupmember_get_response']['group_member_list']
    end
  end	

end