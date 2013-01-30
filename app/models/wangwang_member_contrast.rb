# -*- encoding : utf-8 -*-
class WangwangMemberContrast
  include Mongoid::Document
  field :account_id,                   type: Integer
  field :user_id,                      type: String
  field :created_at,                   type: DateTime

  field :daily_reply_count,            type: Integer
  field :daily_inquired_count,         type: Integer
  field :yesterday_created_count,      type: Integer
  field :yesterday_created_payment,    type: Float
  field :daily_paid_count,             type: Integer
  field :daily_paid_payment,           type: Float

  field :daily_created_count,          type: Integer
  field :daily_created_payment,        type: Float
  field :tomorrow_lost_count,          type: Integer
  field :tomorrow_created_count,       type: Integer
  field :tomorrow_created_payment,     type: Float

  field :yesterday_lost_count,         type: Integer
  field :yesterday_lost_payment,       type: Float
  field :yesterday_paid_count,         type: Integer
  field :yesterday_paid_payment,       type: Float
  field :yesterday_final_paid_count,   type: Integer
  field :yesterday_final_paid_payment, type: Float

  field :daily_quiet_paid_count,       type: Integer
  field :daily_quiet_paid_payment,     type: Float
  field :daily_self_paid_count,        type: Integer
  field :daily_self_paid_payment,      type: Float
  field :daily_others_paid_count,      type: Integer
  field :daily_others_paid_payment,    type: Float

  def self.total_brief_info(start_date, end_date)
    clerk_num = WangwangMember.count
    contrast_info = WangwangMemberContrast.where(:created_at.gte => start_date, :created_at.lt => end_date)
    total_info = []
    total_info[0] = ["汇总"]
    total_info[1] = ["均值"]
    sum_array = [:daily_reply_count,
                 :daily_inquired_count,
                 :yesterday_created_count,
                 :daily_paid_count,
                 :yesterday_created_payment,
                 :daily_paid_payment]
    sum_array.each do |data|
      total_num = contrast_info.try(:sum, data) || 0
      avg_num = (total_num == 0 ? 0 : total_num/clerk_num) || 0
      total_info[0].push(total_num)
      total_info[1].push(avg_num)
    end
    total_info
  end

  def self.total_inquired_and_created(start_date, end_date)
    clerk_num = WangwangMember.count
    contrast_info = WangwangMemberContrast.where(:created_at.gte => start_date, :created_at.lt => end_date)
    total_info = []
    total_info[0] = ["汇总"]
    total_info[1] = ["均值"]
    sum_array = [:daily_inquired_count,
                 :tomorrow_lost_count,
                 :daily_created_count,
                 :daily_created_payment,
                 :tomorrow_created_count,
                 :tomorrow_created_payment]
    sum_array.each do |data|
      total_num = contrast_info.try(:sum, data) || 0
      avg_num = (total_num == 0 ? 0 : total_num/clerk_num) || 0
      total_info[0].push(total_num)
      total_info[1].push(avg_num)
    end
    total_info
  end

  def self.total_created_and_paid(start_date, end_date)
    clerk_num = WangwangMember.count
    contrast_info = WangwangMemberContrast.where(:created_at.gte => start_date, :created_at.lt => end_date)
    total_info = []
    total_info[0] = ["汇总"]
    total_info[1] = ["均值"]
    sum_array = [:yesterday_created_count,
                 :yesterday_created_payment,
                 :yesterday_lost_count,
                 :yesterday_lost_payment,
                 :yesterday_paid_count,
                 :yesterday_paid_payment,
                 :yesterday_final_paid_count,
                 :yesterday_final_paid_payment]
    sum_array.each do |data|
      total_num = contrast_info.try(:sum, data) || 0
      avg_num = (total_num == 0 ? 0 : total_num/clerk_num) || 0
      total_info[0].push(total_num)
      total_info[1].push(avg_num)
    end
    total_info
  end

  def self.total_followed_paid(start_date, end_date)
    clerk_num = WangwangMember.count
    contrast_info = WangwangMemberContrast.where(:created_at.gte => start_date, :created_at.lt => end_date)
    total_info = []
    total_info[0] = ["汇总"]
    total_info[1] = ["均值"]
    sum_array = [:daily_paid_count,
                 :daily_quiet_paid_count,
                 :daily_others_paid_count,
                 :daily_self_paid_count,
                 :daily_paid_payment,
                 :daily_quiet_paid_payment,
                 :daily_others_paid_payment,
                 :daily_self_paid_payment
                 ]
    sum_array.each do |data|
      total_num = contrast_info.try(:sum, data) || 0
      avg_num = (total_num == 0 ? 0 : total_num/clerk_num) || 0
      total_info[0].push(total_num)
      total_info[1].push(avg_num)
    end
    total_info
  end

end