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

  def self.total_brief_info(start_date, end_date)
    clerk_num = WangwangMember.count
    contrast_info = WangwangMemberContrast.where(:created_at.gte => start_date, :created_at.lt => end_date)

    #当日接待
    total_reply_num = contrast_info.try(:sum, :daily_reply_count) || 0
    avg_reply_num = (total_reply_num == 0 ? 0 : total_reply_num/clerk_num)

    #当日询单（该数据须延迟一天统计)
    total_inquired_num = contrast_info.try(:sum, :daily_inquired_count) || 0
    avg_inquired_num = (total_inquired_num == 0 ? 0 : total_inquired_num/clerk_num)

    #下单人数
    total_created_num = contrast_info.try(:sum, :daily_created_count) || 0
    avg_created_num = (total_created_num == 0 ? 0 : total_created_num/clerk_num)

    #下单金额
    total_created_payment = contrast_info.try(:sum, :daily_created_payment) || 0
    avg_created_payment = (total_created_payment == 0 ? 0 : total_created_payment/clerk_num)

    #付款人数
    total_paid_num = contrast_info.try(:sum, :daily_paid_num) || 0
    avg_paid_num = (total_paid_num == 0 ? 0 : total_paid_num/clerk_num)

    #付款金额
    total_paid_payment = contrast_info.try(:sum, :daily_paid_payment) || 0
    avg_paid_payment = (total_paid_payment == 0 ? 0 : total_paid_payment/clerk_num)

    total_brief_info = []
    total_brief_info[0] = ["汇总", total_reply_num.to_i, total_inquired_num.to_i, total_created_num.to_i, total_paid_num.to_i, total_created_payment.round(2), total_paid_payment.round(2)]
    total_brief_info[1] = ["均值", avg_reply_num.round(1), avg_inquired_num.round(1), avg_created_num.round(1), avg_paid_num.round(1), avg_created_payment.round(2), total_paid_payment.round(2)]

    total_brief_info
  end

  def chatpeers(start_date, end_date)
    WangwangChatpeer.where(user_id: service_staff_id).where(:date.gte => start_date, :date.lt => end_date).map(&:buyer_nick)
  end

  # def inquired_and_created
  #   #当日询单人数（延迟一天统计）
  #   inquired_num = WangwangChatpeer.where(user_id: service_staff_id).where(:date.gte => start_date, :date.lt => end_date).map(&:buyer_nick).count
  #   #当日询单，当日次日均未下单（延迟一天统计）
  #   inquired_today = WangwangChatpeer.where(user_id: service_staff_id).where(:date.gte => start_date, :date.lt => end_date).map(&:buyer_nick).uniq.count
  #   didnt_created_num = (inquired_today - TaobaoTrade.only(:buyer_nick, :created, :payment).where(:created.gte => start_date, :created.lt => (end_date ＋ 1.day)).where(:buyer_nick.in => inquired_today).map(&:buyer_nick).uniq
  #   #当日询单下单人数
  #   created_today_num = TaobaoTrade.where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => inquired_today).map(&:buyer_nick).uniq.count
  #   #当日询单下单金额
  #   created_today_payment = TaobaoTrade.where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => inquired_today).sum(:payment) || 0
  #   #当日询单，当日次日下单人数
  #   created_today_and_tomorrow = TaobaoTrade.where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => inquired_today).map(&:buyer_nick).uniq.count
  #   #当日询单，当日次日下单金额
  #   created_today_and_tomorrow_payment = TaobaoTrade.where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => inquired_today).sum(:payment) || 0
  #   #最终下单人数/询单人数
  #   success_ratio = (created_today_and_tomorrow/inquired_today*100)
  # end

  # def self.total_inquired_and_created
  #   clerk_num = WangwangMember.count
  #   total_inquired_num = WangwangChatpeer.where(:date.gte => start_date, :date.lt => end_date).map(&:buyer_nick).count
  #   avg_inquired_num = WangwangChatpeer.where(:date.gte => start_date, :date.lt => end_date).map(&:buyer_nick).count/clerk_num

  #   total_inquired_today = WangwangChatpeer.where(:date.gte => start_date, :date.lt => end_date).map(&:buyer_nick).uniq
  #   avg_inquired_today = WangwangChatpeer.where(:date.gte => start_date, :date.lt => end_date).map(&:buyer_nick).uniq/clerk_num

  #   total_didnt_created_num = (inquired_today - TaobaoTrade.only(:buyer_nick, :created, :payment).where(:created.gte => start_date, :created.lt => (end_date ＋ 1.day)).where(:buyer_nick.in => total_inquired_today).map(&:buyer_nick).uniq.count
  #   avg_didnt_created_num = (inquired_today - TaobaoTrade.only(:buyer_nick, :created, :payment).where(:created.gte => start_date, :created.lt => (end_date ＋ 1.day)).where(:buyer_nick.in => total_inquired_today).map(&:buyer_nick).uniq.count/clerk_num 

  #   total_created_today_num = TaobaoTrade.where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => total_inquired_today).map(&:buyer_nick).uniq.count
  #   avg_created_today_num = TaobaoTrade.where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => total_inquired_today).map(&:buyer_nick).uniq.count/clerk_num

  #   total_created_today_payment = TaobaoTrade.where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => total_inquired_today).sum(:payment) || 0
  #   avg_created_today_payment = TaobaoTrade.where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => total_inquired_today).sum(:payment)/clerk_num

  #   total_created_today_and_tomorrow = TaobaoTrade.where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => total_inquired_today).map(&:buyer_nick).uniq.count
  #   avg_created_today_and_tomorrow = TaobaoTrade.where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => total_inquired_today).map(&:buyer_nick).uniq.count/clerk_num

  #   total_created_today_and_tomorrow_payment = TaobaoTrade.where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => total_inquired_today).sum(:payment) || 0
  #   avg_created_today_and_tomorrow_payment = TaobaoTrade.where(:created.gte => start_date, :created.lt => end_date).where(:buyer_nick.in => total_inquired_today).sum(:payment)/clerk_num
  # end

end