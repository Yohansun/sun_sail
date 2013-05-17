#encoding: utf-8
class CustomersPuller
  class << self
    def initialize!
      raise "already initialized!" if Customer.count > 1
      find_or_create(TaobaoTrade.desc(:tid))
    end
    
    def update
      news_taobao_trades = TaobaoTrade.where(:news => 1)
      
      find_or_create(news_taobao_trades) do |taobao_trade|
        taobao_trade.news = 2
        taobao_trade.save(:validate => false)
      end
      
    end
    
    def sync
      customer = Customer.desc("transaction_histories.tid").first
      latest_transaction_history = customer.transaction_histories.first
      news_trades = TaobaoTrade.desc("tid").where(:tid => {"$gt" => (latest_transaction_history.tid || 0)})
      find_or_create(news_trades)
    end
    
    private
    def customer_keys
      Customer.fields.except("_id","_type").keys
    end
    
    def transaction_history_fields
      TransactionHistory.fields.except("_id","_type").keys
    end
    
    def find_or_create(news_trades,&block)
      news_trades.each do |taobao_trade|
        customer = Customer.find_or_create_by(:name => taobao_trade.buyer_nick)
        customer.transaction_histories.build do |transaction_history|
          transaction_history.attributes = taobao_trade.attributes.slice(*transaction_history_fields)
        end
        customers_attributes = parse_attributes(taobao_trade.attributes)

        customer.update_attributes(customers_attributes)
        
        yield(taobao_trade) if block_given?
      end
      
    end
    
    def parse_attributes(attrs)
      {"buyer_nick" => "name","buyer_email" => "email"}.each_pair do |k,v|
        attrs[v] = attrs.delete(k)
      end
      attrs.slice(*customer_keys)
    end
  end
end