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

end