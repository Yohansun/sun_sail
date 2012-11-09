#-*- encoding :utf-8 -*-

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

  def all_trade_fee(start_time, end_time)
    all_trades = Trade.where("$and" => [{:created.gte => start_time.utc - 8.hour }, {:created.lte => end_time.utc - 8.hour}])
    all_money = all_trades.inject(0) { |sum, trade| sum + trade.calculate_fee }
    all_money.to_i
  end

  def paid_trade_fee(start_time, end_time)
    paid_trades = Trade.where("$and" => [{:created.gte => self.start_at.utc - 8.hour }, {:pay_time.gte => start_time.utc - 8.hour }, {:pay_time.lte => end_time.utc - 8.hour }])
    if paid_trades
      paid_money = paid_trades.inject(0) { |sum, trade| sum + trade.calculate_fee }
      paid_money.to_i
    end
  end

end