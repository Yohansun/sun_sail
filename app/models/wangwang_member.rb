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

  def self.find_with_service_staff_id(service_staff_id)
  	user_id = service_staff_id.gsub("cntaobao", "")
  	where(user_id: user_id).first
  end

  def clerk_brief_info(start_date, end_date)
    inquired_today = WangwangChatpeer.where(user_id: service_staff_id).where(:date.gte => start_date, :date.lt => end_date).map(&:buyer_nick)
    inquired_today_and_yesterday = WangwangChatpeer.where(user_id: service_staff_id).where(:date.gte => (start_date - 1.day), :date.lt => end_date).map(&:buyer_nick)

    #当日接待
    served_num = WangwangReplyState.where(user_id: service_staff_id).where(:reply_date.gte => start_date, :reply_date.lt => end_date).sum(:reply_num) || 0

    #当日询单（该数据须延迟一天统计)
    inquired_num = WangwangChatpeer.where(user_id: service_staff_id).where(:date.gte => start_date, :date.lt => end_date).map(&:buyer_nick).count

    #下单订单: 前一日或当日询单，本旺旺落实当日下单订单
    created_trades = TaobaoTrade.only(:buyer_nick, :created, :payment).where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => inquired_today_and_yesterday)

    #下单人数
    created_num = created_trades.try(:map, &:buyer_nick).uniq.count

    #下单金额
    created_payment = created_trades.try(:sum, :payment) || 0

    #付款订单: 本旺旺落实当日付款订单
    paid_trades = TaobaoTrade.only(:buyer_nick, :pay_time, :payment).where(:pay_time.gte => start_date, :pay_time.lt => end_date).where(:buyer_nick.in => inquired_today)

    #付款人数
    paid_num = paid_trades.try(:map, &:buyer_nick).uniq.count

    #付款金额
    paid_payment = paid_trades.try(:sum, :payment) || 0

    [self.short_id, served_num.to_i, inquired_num.to_i, created_num.to_i, paid_num.to_i, created_payment, paid_payment]
  end

  def self.total_brief_info(start_date, end_date)
    clerk_num = WangwangMember.count
    inquired_today = WangwangChatpeer.where(:date.gte => start_date, :date.lt => end_date).map(&:buyer_nick)
    inquired_today_and_yesterday = WangwangChatpeer.where(:date.gte => (start_date - 1.day), :date.lt => end_date).map(&:buyer_nick)

    #当日接待
    total_served_num = WangwangReplyState.where(:reply_date.gte => start_date, :reply_date.lt => end_date).sum(:reply_num) || 0
    avg_served_num = total_served_num/clerk_num

    #当日询单（该数据须延迟一天统计)
    total_inquired_num = WangwangChatpeer.where(:date.gte => start_date, :date.lt => end_date).map(&:buyer_nick).count
    avg_inquired_num = total_inquired_num/clerk_num

    #下单订单: 前一日或当日询单，本旺旺落实当日下单订单
    total_created_trade = TaobaoTrade.only(:buyer_nick, :created, :payment).where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => inquired_today_and_yesterday)

    #下单人数
    total_created_num = total_created_trade.try(:map, &:buyer_nick).uniq.count
    avg_created_num = total_created_num/clerk_num

    #下单金额
    total_created_payment = total_created_trade.try(:sum, :payment) || 0
    avg_created_payment = total_created_payment/clerk_num

    #付款订单: 本旺旺落实当日付款订单
    total_paid_trade = TaobaoTrade.only(:buyer_nick, :pay_time, :payment).where(:pay_time.gte => start_date, :pay_time.lt => end_date).where(:buyer_nick.in => inquired_today)

    #付款人数
    total_paid_num = total_paid_trade.try(:map, &:buyer_nick).uniq.count
    avg_paid_num = total_paid_num/clerk_num

    #付款金额
    total_paid_payment = total_paid_trade.try(:sum, :payment) || 0
    avg_paid_payment = total_paid_payment/clerk_num

    total_brief_info = []
    total_brief_info[0] = ["汇总", total_served_num.to_i, total_inquired_num.to_i, total_created_num.to_i, total_paid_num.to_i, total_created_payment.round(2), total_paid_payment.round(2)]
    total_brief_info[1] = ["均值", avg_served_num.round(1), avg_inquired_num.round(1), avg_created_num.round(1), avg_paid_num.round(1), avg_created_payment.round(2), total_paid_payment.round(2)]

    total_brief_info
  end

end