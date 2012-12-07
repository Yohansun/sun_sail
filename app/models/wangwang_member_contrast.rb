# -*- encoding : utf-8 -*-
class WangwangMemberContrast
  include Mongoid::Document
  
  field :user_id,                     type: String
  field :created_at,                  type: DateTime

  field :daily_reply_count,           type: Integer
  field :daily_inquired_count,        type: Integer
  field :daily_created_count,         type: Integer
  field :daily_created_payment,       type: Float
  field :daily_paid_count,            type: Integer
  field :daily_paid_payment,          type: Float

  field :two_days_lost_count,         type: Integer
  field :two_days_created_count,      type: Integer
  field :two_days_created_payment,    type: Float

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

  def self.total_inquired_and_created(start_date, end_date)
    clerk_num = WangwangMember.count
    contrast_info = WangwangMemberContrast.where(:created_at.gte => start_date, :created_at.lt => end_date)

    total_inquired_num = contrast_info.try(:sum, :daily_inquired_count) || 0
    avg_inquired_num = (total_inquired_num == 0 ? 0 : total_inquired_num/clerk_num)

    total_two_days_lost_count = contrast_info.try(:sum, :two_days_lost_count) || 0
    avg_two_days_lost_count = (total_two_days_lost_count == 0 ? 0 : total_two_days_lost_count/clerk_num)

    total_created_num = contrast_info.try(:sum, :daily_created_count) || 0
    avg_created_num = (total_created_num == 0 ? 0 : total_created_num/clerk_num)

    total_created_payment = contrast_info.try(:sum, :daily_created_payment) || 0
    avg_created_payment = (total_created_payment == 0 ? 0 : total_created_payment/clerk_num)

    total_two_days_created_count = contrast_info.try(:sum, :daily_created_payment) || 0
    avg_two_days_created_count = (total_two_days_created_count == 0 ? 0 : total_two_days_created_count/clerk_num)

    total_two_days_created_payment = contrast_info.try(:sum, :daily_created_payment) || 0
    avg_two_days_created_payment = (total_two_days_created_payment == 0 ? 0 : total_two_days_created_payment/clerk_num)

    total_brief_info = []
    total_brief_info[0] = ["汇总", total_inquired_num.to_i, total_two_days_lost_count.to_i, total_created_num.to_i, total_created_payment.to_i, total_two_days_created_count.round(2), total_two_days_created_payment.round(2)]
    total_brief_info[1] = ["均值", avg_inquired_num.round(1), avg_two_days_lost_count.round(1), avg_created_num.round(1), avg_created_payment.round(1), avg_two_days_created_count.round(2), avg_two_days_created_payment.round(2)]

    total_brief_info
  end

end