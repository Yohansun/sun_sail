# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: sales
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  earn_guess :float
#  start_at   :datetime
#  end_at     :datetime
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  account_id :integer(4)
#

class Sale < ActiveRecord::Base
  attr_accessible :name, :earn_guess, :start_at, :end_at
  validates_presence_of :name, :earn_guess, :start_at, :end_at, message: "信息不能为空"

  def time_gap
    gap = (self.end_at - self.start_at).to_i
    second = gap%60
    total_minute = gap/60
    minute = total_minute%60
    total_hour = total_minute/60
    hour = total_hour%24
    day = total_hour/24
    gap = [day.to_s,(hour.to_s + ":" + minute.to_s + ":" + second.to_s)]
  end

  # def all_trade_fee(start_time, end_time)
  #   all_money = Trade.where("$and" => [{:created.gte => start_time.utc - 8.hour }, {:created.lt => end_time.utc - 8.hour}]).sum(:payment).to_f.round(2)
  # end
  # def paid_trade_fee(start_time, end_time)
  #   paid_trades = Trade.where("$and" => [{:pay_time.gte => start_time.utc - 8.hour }, {:pay_time.lt => end_time.utc - 8.hour }]).sum(:payment).to_f.round(2)
  # end

end
