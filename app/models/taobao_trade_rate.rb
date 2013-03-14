# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: taobao_trade_rates
#
#  id         :integer(4)      not null, primary key
#  tid        :string(255)
#  oid        :string(255)
#  role       :string(255)
#  nick       :string(255)
#  result     :text
#  created    :datetime
#  rated_nick :string(255)
#  item_title :string(255)
#  item_price :float
#  content    :string(255)
#  reply      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require "csv"
class TaobaoTradeRate < ActiveRecord::Base
  validates_uniqueness_of :oid
  attr_accessible  :tid, :oid, :content, :created, :item_price, :item_title, :nick, :rated_nick, :result, :role, :reply

  after_create :write_created_to_mongo

  def write_created_to_mongo
    TaobaoTrade.where(tid: tid).update_all(rate_created: created) 
  end 
  
  def self.export_reports(start_time = nil, end_time = nil, time_type = nil)
    start_time ||= Time.now - 7.day
    end_time ||= Time.now

    if time_type == "rate_created"
      trade_rates = TaobaoTradeRate.where(:created => start_time..end_time)
    else
      rated_tids = TaobaoTrade.only(:tid, :created).where(:created => start_time..end_time).all.map(&:tid)
      trade_rates = TaobaoTradeRate.where("tid in (#{rated_tids.join(',')})")
    end
    account = Trade.where(tid: trade_rates.first.tid).first.fetch_account if trade_rates.any?
    CSV.open("data/taobao_rates.csv", 'wb') do |csv|
      if account.try(:key) == "nippon"
        csv << ['订单号','下单时间','送货经销商','销售部','买家地址-省','买家地址-市', '商品名','买家评价结果','评价内容','买家评价时间','旺旺号']
      else
        csv << ['订单号','下单时间','送货经销商','买家地址-省','买家地址-市', '商品名','买家评价结果','评价内容','买家评价时间','旺旺号']
      end
      trade_rates.each do |rate|
        tid = rate.tid
        order = TaobaoTrade.where(tid: tid).first
        if order
          if account.try(:key) == "nippon"
            seller_name = order.seller.try :get_username
            interface_name = order.seller.try(:interface_name)
          else
            seller_name = order.seller_name
          end
          order_created = order.created.strftime("%Y-%m-%d %H:%M:%S")
          state = order.receiver_state
          city = order.receiver_city
          title = rate.item_title
          result = rate.result
          content = rate.content.gsub(',','，').gsub("\n", '.').gsub("\r", '.').gsub("\t", '.')
          rate_created = rate.created.strftime("%Y-%m-%d %H:%M:%S")
          buyer_nick = rate.nick
          if account.try(:key) == "nippon"
            csv << [tid, order_created, seller_name, interface_name, state, city, title, result, content, rate_created, buyer_nick]
          else
            csv << [tid, order_created, seller_name, state, city, title, result, content, rate_created, buyer_nick]
          end
        else
          p "#{tid} not found!"
        end
      end
    end
  end

end
