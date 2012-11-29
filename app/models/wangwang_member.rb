# -*- encoding : utf-8 -*-
class WangwangMember
  include Mongoid::Document
  field :user_id, type: String
  field :name,    type: String
  field :decs,    type: String
  validates_uniqueness_of :user_id
  validates_presence_of :user_id

  def service_staff_id
  	"cntaobao" + user_id
  end

  def short_id
    name || user_id.gsub("立邦漆官方旗舰店:","")
  end

  def self.find_with_staff_id(service_staff_id) 
  	user_id = service_staff_id.gsub("cntaobao", "")
  	where(user_id: user_id).first
  end	
  

  #当日接待总人数
  
  def self.receivenum(start_date, end_date)
    WangwangReplyState.where(:reply_date.gte => start_date, :reply_date.lt => end_date).sum(:reply_num) || 0
  end 

  def self.avg_receivenum(start_date, end_date)
    (WangwangMember.receivenum(start_date, end_date) / WangwangMember.count).to_f.round(4)
  end

  def receivenum(start_date, end_date)
    WangwangReplyState.where(user_id: service_staff_id).where(:reply_date.gte => start_date, :reply_date.lt => end_date).sum(:reply_num) || 0
  end

  #当日询单人（该数据须延迟一天统计）

  def self.chatpeers(start_date, end_date)
    WangwangChatpeer.where(:date.gte => start_date, :date.lt => end_date).map(&:buyer_nick)
  end 
 
  def self.chatpeers_count(start_date, end_date)
    WangwangMember.chatpeers(start_date, end_date).count
  end

  def self.avg_chatpeers_count(start_date, end_date)
    (WangwangMember.chatpeers_count(start_date, end_date) / WangwangMember.count).to_f.round(4)
  end

  def chatpeers(start_date, end_date)
    WangwangChatpeer.where(user_id: service_staff_id).where(:date.gte => start_date, :date.lt => end_date).map(&:buyer_nick)
  end

  def chatpeers_count(start_date, end_date)
    chatpeers(start_date, end_date).count
  end

  #当日下单

  def self.current_created_trade(start_date, end_date)
    WangwangMember.created_trade(start_date, end_date) - WangwangMember.paid_trade(start_date, end_date)
  end

  def self.current_created_trade_buyer_count(start_date, end_date)
    WangwangMember.current_created_trade(start_date, end_date).try(:map, &:buyer_nick).uniq.count
  end 

  def self.current_created_trade_payment(start_date, end_date)
    if WangwangMember.current_created_trade(start_date, end_date).present?
      WangwangMember.current_created_trade(start_date, end_date).try(:sum, :payment) 
    else  
      0
    end
  end

  def self.avg_current_created_trade_buyer_count(start_date, end_date)
    (WangwangMember.current_created_trade_buyer_count(start_date, end_date) / WangwangMember.count).to_f.round(4)
  end 

  def self.avg_current_created_trade_payment(start_date, end_date)
    (WangwangMember.current_created_trade_payment(start_date, end_date) / WangwangMember.count).to_f.round(4)
  end

  def current_created_trade_buyer_count(start_date, end_date)
    current_created_trade(start_date, end_date).try(:map, &:buyer_nick).uniq.count
  end 

  def current_created_trade_payment(start_date, end_date)
    current_created_trade(start_date, end_date).try(:sum, :payment) || 0
  end

  def current_trade(start_date, end_date)
    created_trade(start_date, end_date) - paid_trade(start_date, end_date)
  end  

  def current_created_trade(start_date, end_date)
    TaobaoTrade.only(:buyer_nick, :created, :pay_time, :payment).where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => chatpeers(start_date, end_date))
  end

  #下单订单: 前一日或当日询单，本旺旺落实当日下单订单
  def self.created_trade(start_date, end_date)
    adjust_date = (start_date.to_time - 1.day).strftime("%Y-%m-%d %H:%M:%S")
    TaobaoTrade.only(:buyer_nick, :created, :pay_time, :payment).where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => WangwangMember.chatpeers(adjust_date, end_date))
  end

  def self.created_trade_buyer_count(start_date, end_date)
    WangwangMember.created_trade(start_date, end_date).try(:map, &:buyer_nick).uniq.count
  end 

  def self.created_trade_payment(start_date, end_date)
    WangwangMember.created_trade(start_date, end_date).try(:sum, :payment) || 0
  end

  def self.avg_created_trade_buyer_count(start_date, end_date)
    (WangwangMember.created_trade_buyer_count(start_date, end_date) / WangwangMember.count).to_f.round(4)
  end 

  def self.avg_created_trade_payment(start_date, end_date)
    (WangwangMember.created_trade_payment(start_date, end_date) / WangwangMember.count).to_f.round(4)
  end

  def created_trade(start_date, end_date)
    adjust_date = (start_date.to_time - 1.day).strftime("%Y-%m-%d %H:%M:%S")
    trades = TaobaoTrade.only(:buyer_nick, :created, :pay_time, :payment).where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => chatpeers(adjust_date, end_date))
  end

  def created_trade_buyer_count(start_date, end_date)
    created_trade(start_date, end_date).try(:map, &:buyer_nick).uniq.count
  end 

  def created_trade_payment(start_date, end_date)
    created_trade(start_date, end_date).try(:sum, :payment) || 0
  end

  #最终下单人:当日询单，且本旺旺落实当日或次日下单
  def self.final_created_trade(start_date, end_date)
    adjust_date = (end_date.to_time + 1.day).strftime("%Y-%m-%d %H:%M:%S")
    TaobaoTrade.only(:buyer_nick, :created, :pay_time, :payment).where(:created.gte => start_date, :created.lt => adjust_date).where(:buyer_nick.in => WangwangMember.chatpeers(start_date, end_date))
  end

  def self.final_created_trade_buyer_count(start_date, end_date)
    WangwangMember.final_created_trade(start_date, end_date).try(:map, &:buyer_nick).uniq.count
  end 

  def self.final_created_trade_payment(start_date, end_date)
    WangwangMember.final_created_trade(start_date, end_date).try(:sum, :payment) || 0
  end

  def self.avg_final_created_trade_buyer_count(start_date, end_date)
    (WangwangMember.final_created_trade_buyer_count(start_date, end_date) / WangwangMember.count).to_f.round(4)
  end 

  def self.avg_final_created_trade_payment(start_date, end_date)
    (WangwangMember.final_created_trade_payment(start_date, end_date) / WangwangMember.count).to_f.round(4)
  end

  def final_created_trade_buyer_count(start_date, end_date)
    final_created_trade(start_date, end_date).try(:map, &:buyer_nick).uniq.count
  end 

  def final_created_trade_buyer_count_percentage(start_date, end_date)
    return 0 if  chatpeers(start_date, end_date).count == 0
    (final_created_trade_buyer_count(start_date, end_date) / chatpeers(start_date, end_date).count).to_f.round(4)
  end  

  def final_created_trade_payment(start_date, end_date)
    final_created_trade(start_date, end_date).try(:sum, :payment) || 0
  end

  def final_created_trade(start_date, end_date)
    adjust_date = (end_date.to_time + 1.day).strftime("%Y-%m-%d %H:%M:%S")
    TaobaoTrade.only(:buyer_nick, :created, :pay_time, :payment).where(:created.gte => start_date, :created.lt => adjust_date ).where(:buyer_nick.in => chatpeers(start_date, end_date))
  end

  #付款订单:本旺旺落实当日付款订单
  def self.paid_trade(start_date, end_date)
    TaobaoTrade.only(:buyer_nick, :created, :pay_time, :payment).where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => WangwangMember.chatpeers(start_date, end_date))
  end

  def self.paid_trade_buyer_count(start_date, end_date)
    WangwangMember.paid_trade(start_date, end_date).try(:map, &:buyer_nick).uniq.count
  end 

  def self.paid_trade_payment(start_date, end_date)
    WangwangMember.paid_trade(start_date, end_date).try(:sum, :payment) || 0
  end

  def self.avg_paid_trade_buyer_count(start_date, end_date)
    (WangwangMember.paid_trade_buyer_count(start_date, end_date) / WangwangMember.count).to_f.round(4)
  end 

  def self.avg_paid_trade_payment(start_date, end_date)
    (WangwangMember.paid_trade_payment(start_date, end_date) / WangwangMember.count).to_f.round(4)
  end

  def paid_trade_buyer_count(start_date, end_date)
    paid_trade(start_date, end_date).try(:map, &:buyer_nick).uniq.count
  end 

  def paid_trade_payment(start_date, end_date)
    paid_trade(start_date, end_date).try(:sum, :payment) || 0
  end

  def paid_trade(start_date, end_date)
    TaobaoTrade.only(:buyer_nick, :created, :pay_time, :payment).where(:pay_time.gte => start_date, :pay_time.lt => end_date).where(:buyer_nick.in => chatpeers(start_date, end_date))
  end

  def paid_trade_payment_percentage(start_date, end_date)
    return 0 if WangwangMember.paid_trade_payment(start_date, end_date) == 0
    (paid_trade_payment(start_date, end_date) / WangwangMember.paid_trade_payment(start_date, end_date)).to_f.round(4) * 100
  end

  #当日付款:前一日或当日询单，本旺旺落实当日下单且当日付款
  #最终付款:前一日或当日询单，本旺旺落实当日下单且最终付款人数（该数据须延迟四天统计）
  def self.final_paid_trade(start_date, end_date)
    adjust_date = (end_date.to_time + 1.day).strftime("%Y-%m-%d %H:%M:%S")
    adjust_chat_date = (start_date.to_time - 1.day).strftime("%Y-%m-%d %H:%M:%S")
    TaobaoTrade.only(:buyer_nick, :created, :pay_time, :payment).where(:created.gte => start_date, :created.lt => adjust_date, :pay_time.gte => start_date, :pay_time.lt => adjust_date).where(:buyer_nick.in => WangwangMember.chatpeers(adjust_chat_date, end_date))
  end

  def self.final_paid_trade_buyer_count(start_date, end_date)
    WangwangMember.final_paid_trade(start_date, end_date).try(:map, &:buyer_nick).uniq.count
  end 

  def self.final_paid_trade_payment(start_date, end_date)
    if WangwangMember.final_paid_trade(start_date, end_date).present?
      WangwangMember.final_paid_trade(start_date, end_date).try(:sum, :payment) 
    else  
      0
    end  
  end

  def self.avg_final_paid_trade_buyer_count(start_date, end_date)
    (WangwangMember.final_paid_trade_buyer_count(start_date, end_date) / WangwangMember.count).round(4)
  end 

  def self.avg_final_paid_trade_payment(start_date, end_date)
    (WangwangMember.final_paid_trade_payment(start_date, end_date) / WangwangMember.count).round(4)
  end

  def final_paid_trade_buyer_count(start_date, end_date)
    final_paid_trade(start_date, end_date).try(:map, &:buyer_nick).uniq.count
  end 

  def final_paid_trade_buyer_count_percentage(start_date, end_date)
    return 0 if  chatpeers(start_date, end_date).count == 0
    (final_paid_trade_buyer_count(start_date, end_date) / created_trade_buyer_count(start_date, end_date)).round(4)
  end 

  def final_paid_trade_payment(start_date, end_date)
    paid_trade(start_date, end_date).try(:sum, :payment) || 0
  end

  def final_paid_trade(start_date, end_date)
    adjust_date = (end_date.to_time + 1.day).strftime("%Y-%m-%d %H:%M:%S")
    adjust_chat_date = (start_date.to_time - 1.day).strftime("%Y-%m-%d %H:%M:%S")
    TaobaoTrade.only(:buyer_nick, :created, :pay_time, :payment).where(:created.gte => start_date, :created.lt => adjust_date, :pay_time.gte => start_date, :pay_time.lt => adjust_date).where(:buyer_nick.in => chatpeers(adjust_chat_date, end_date))
  end

  # 流失人 :当日询单，但当日和次日均未下单人
  def lost_created_chatpeers(start_date, end_date)
    adjust_date = (end_date.to_time + 1.day).strftime("%Y-%m-%d %H:%M:%S")
    chatpeers(start_date, end_date) - created_trade(start_date, adjust_date).map(&:buyer_nick) 
  end 

  def self.lost_created_chatpeers(start_date, end_date)
    adjust_date = (end_date.to_time + 1.day).strftime("%Y-%m-%d %H:%M:%S")
    (WangwangMember.chatpeers(start_date, end_date) - WangwangMember.created_trade(start_date, adjust_date).map(&:buyer_nick)).count 
  end

  def self.avg_lost_created_chatpeers(start_date, end_date)
    (WangwangMember.lost_created_chatpeers(start_date, end_date) / WangwangMember.count).round(4)
  end 

  #前一日或当日询单，本旺旺落实当日下单但最终未付款

  def self.lost_paid_trade(start_date, end_date)
    WangwangMember.created_trade(start_date, end_date) - WangwangMember.paid_trade(start_date, end_date)
  end

  def self.lost_paid_trade_buyer_count(start_date, end_date)
    WangwangMember.lost_paid_trade(start_date, end_date).try(:map, &:buyer_nick).uniq.count
  end 

  def self.lost_paid_trade_payment(start_date, end_date)
    WangwangMember.lost_paid_trade(start_date, end_date).try(:sum, :payment) || 0
  end

  def self.avg_lost_paid_trade_buyer_count(start_date, end_date)
    (WangwangMember.lost_paid_trade_buyer_count(start_date, end_date) / WangwangMember.count).round(4)
  end 

  def self.avg_lost_paid_trade_payment(start_date, end_date)
    (WangwangMember.lost_paid_trade_payment(start_date, end_date) / WangwangMember.count).round(4)
  end

  def lost_paid_trade_buyer_count(start_date, end_date)
    lost_paid_trade(start_date, end_date).try(:map, &:buyer_nick).uniq.count
  end 

  def lost_paid_trade_payment(start_date, end_date)
    if lost_paid_trade(start_date, end_date).present?
      lost_paid_trade(start_date, end_date).try(:sum, :payment)
    else
      0
    end 
  end

  def lost_paid_trade(start_date, end_date)
    created_trade(start_date, end_date) - paid_trade(start_date, end_date)
  end 

end