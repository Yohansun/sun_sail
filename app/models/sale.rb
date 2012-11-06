#-*- encoding :utf-8 -*-

class Sale < ActiveRecord::Base
  attr_accessible :name, :earn_guess, :start_at, :end_at

  # start_at = self.start_at.to_time
  # end_at = self.end_at.to_time

  def time_gap
    # if Time.now > self.end_at.to_time || Time.now < self.start_at.to_time
    #   ["00",("00:00:00")]
    # else
      gap = (self.end_at - self.start_at).to_i
      second = gap%60
      total_minute = gap/60
      minute = total_minute%60
      total_hour = total_minute/60
      hour = total_hour%24
      day = total_hour/24
      gap = [day.to_s,(hour.to_s + ":" + minute.to_s + ":" + second.to_s)]
    # end
  end

  def all_trade_fee
    all_trades = TradeDecorator.decorate(Trade.where("$and" => [{:created.gte => (self.start_at.to_time)},{:created.lte => (self.start_at.to_time + 10.hours)}]))
    if all_trades
      p all_trades.count
      all_money = all_trades.inject(0) { |sum, trade| sum + trade.total_fee.to_f }
      all_money.round(2)
    end
  end

  def paid_trade_fee
    paid_trades = TradeDecorator.decorate(Trade.where("$and" => [{:pay_time.gte => (self.start_at.to_time)},{:pay_time.lte => (self.start_at.to_time + 10.hours)}]))
    if paid_trades
      p paid_trades.count
      paid_money = paid_trades.inject(0) { |sum, trade| sum + trade.total_fee.to_f }
      paid_money.round(2)
    end
  end

  def money_percent_bar
    ((self.paid_trade_fee/self.earn_guess)* 100).to_i.to_s + "%"
  end
end