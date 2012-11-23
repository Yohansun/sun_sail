class Wangwang 

	START_DATE = Time.now.yesterday.beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")
	END_DATE = Time.now.yesterday.end_of_day.strftime("%Y-%m-%d %H:%M:%S")

  def self.get(start_date = nil, end_date = nil, service_staff_ids = nil)
    service_staff_ids ||= WangwangMember.all.map &:service_staff_id
    start_date ||= START_DATE
    end_date ||= END_DATE
    service_staff_ids.each do |service_staff_id|
      chatpeers_get(start_date, end_date, service_staff_id)
      receivenum_get(start_date, end_date, service_staff_id)
    end  
  end

  def self.chatpeers_get(start_date = nil, end_date = nil, chat_id = nil)
  	chat_id ||= TradeSetting.chat_id
    start_date ||= START_DATE
    end_date ||= END_DATE
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
        chatpeers.each do |chatpeer|
      		uid = chatpeer['uid']
      		date = chatpeer['date']
        	chatlog_get(start_date, end_date, chat_id, uid)
        end	
      end  
    end
  end	

  def self.chatlog_get(start_date = nil, end_date = nil, from_id = nil, to_id = nil)
  	chat_id ||= TradeSetting.chat_id
    start_date ||= START_DATE
    end_date ||= END_DATE
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
           time: msg['time'],
           content: msg['content']
          )
        end	
      end  
    end
  end
  	
  # 服务提供时间（7:00:00-24:00:00）
  def self.receivenum_get(start_date = nil, end_date = nil, service_staff_id = nil)
  	service_staff_id ||= TradeSetting.service_staff_id
    start_date ||= START_DATE
    end_date ||= END_DATE 
    response = TaobaoFu.get(
      method: 'taobao.wangwang.eservice.receivenum.get',
      service_staff_id: service_staff_id,
      start_date: start_date,
    	end_date: end_date
    )
    response = response['wangwang_eservice_receivenum_get_response']
    return unless response
    response = response['reply_stat_list_on_days']
    return unless response
    response = response['reply_stat_on_day']
    return unless response 
    unless response.is_a?(Array)
      response = [] << response
    end
    response.each do |rep|
    	reply_date = rep['reply_date']
    	reply_stat_by_ids = rep['reply_stat_by_ids']
      return unless reply_stat_by_ids
      reply_stat_by_ids = reply_stat_by_ids['reply_stat_by_id']   
      return unless reply_stat_by_ids 
      unless reply_stat_by_ids.is_a?(Array)
        reply_stat_by_ids = [] << reply_stat_by_ids
      end
      reply_stat_by_ids.each do |reply_stat_by_id|
      	user_id = reply_stat_by_id['user_id']
      	reply_num = reply_stat_by_id['reply_num']
        WangwangReplyState.create(user_id: reply_stat_by_id['user_id'],
          reply_num: reply_stat_by_id['reply_num'],
          reply_date: reply_date
        )	
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