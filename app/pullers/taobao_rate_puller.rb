# encoding : utf-8 -*-
class TaobaoRatePuller
  class << self
    # Every 1 Day
    def create(start_time = nil, end_time = nil, trade_source_id = nil)
      
      start_time ||= Time.now - 1.day
      end_time ||= Time.now
      trade_source_id ||= TradeSetting.default_taobao_trade_source_id

      response = TaobaoQuery.get({:method => 'taobao.traderates.get',
        :fields => 'tid',
        :start_date => start_time.strftime("%Y-%m-%d %H:%M:%S"),
        :end_date => end_time.strftime("%Y-%m-%d %H:%M:%S"),
        :page_no => 1,
        :page_size => 1,
        :rate_type => 'get',
        :role => 'buyer'}, trade_source_id
        )

      has_next = true
      page_no = 1

      while has_next
        response = TaobaoQuery.get({:method => 'taobao.traderates.get',
          :fields => 'tid, oid, role, nick, result, created, rated_nick, item_title, item_price, content, reply',
          :start_date => start_time.strftime("%Y-%m-%d %H:%M:%S"),
          :end_date => end_time.strftime("%Y-%m-%d %H:%M:%S"),
          :page_no => page_no,
          :page_size => 40,
          :rate_type => 'get',
          :role => 'buyer',
          :use_has_next => true}, trade_source_id
          )

        page_no += 1
        has_next = response['traderates_get_response']['has_next']
        trade_rates = response['traderates_get_response']['trade_rates']['trade_rate']

        
        trade_rates.each do |rate|
          next if TaobaoTradeRate.exists?(["oid = ?", rate['oid']])
          TaobaoTradeRate.create(:tid => rate['tid'].to_s, :oid => rate['oid'], :content => rate['content'], :created => rate['created'], :item_price => rate['item_price'], :item_title => rate['item_title'], :nick => rate['nick'], :rated_nick => rate['rated_nick'], :result => rate['result'], :role => rate['role'], :reply => rate['reply'])
          # UPDATE LogisticRate
          next unless LogisticRate.exists?(["tid = ?", rate['tid']])
          if rate['result'] == "good"
            taobao_rate_score = 5
          elsif rate['result'] == "neutral" 
            taobao_rate_score = 3
          else
            taobao_rate_score = 1
          end    
          logistic_rates = LogisticRate.where(tid: rate['tid'])
          logistic_rates.each do |logistic_rate| 
            logistic_rate.update_attributes!(taobao_rate_score: taobao_rate_score)
          end    
        end
      end
    end
  end    
end    