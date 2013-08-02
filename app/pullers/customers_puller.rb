#encoding: utf-8
class CustomersPuller
  class << self
    def initialize!(account_id=nil)
      conditions = default_condition(account_id)
      customers,trades = Customer.where(conditions),Trade.where(conditions)
      raise "Already initialized!" if customers.count > 1
      find_or_create(trades.desc(:tid))
    end

    def update(account_id=nil)
      conditions = default_condition(account_id).merge({:news => 1})
      news_trades = Trade.where(conditions)

      find_or_create(news_trades) do |trade|
        trade.news = 2
        trade.save(:validate => false)
      end
    end

    def sync(account_id=nil)
      conditions = default_condition(account_id)
      customer = latest_customer(conditions)
      #如果顾客数据为空,先进行初始化
      customer = initialize!(account_id) && latest_customer(conditions) if customer.blank?
      #如果本地订单为空结束同步
      return if customer.blank?
      latest_transaction_history = customer.transaction_histories.first
      conditions.merge!({:tid => {"$gt" => (latest_transaction_history.tid || "0")}})
      news_trades = TaobaoTrade.desc("tid").where(conditions)
      find_or_create(news_trades)
    end

    private
    def latest_customer(conditions={})
      Customer.where(conditions).desc("transaction_histories.tid").first
    end

    def customer_keys
      Customer.fields.except("_id","_type").keys
    end

    def default_condition(account_id=nil)
      conditions = {:_type.in => %w(TaobaoTrade JingdongTrade YihaodianTrade)}
      account_id.present? ? conditions.merge({:account_id => account_id}) : conditions
    end

    def transaction_history_fields
      TransactionHistory.fields.except("_id","_type").keys
    end

    def transaction_history_attributes(trade)
      attrs = trade.attributes.slice(*transaction_history_fields)
      orders = trade.orders
      products = orders.collect {|x| x.products}.flatten.compact
      product_ids = products.collect {|x| x.id rescue nil}.compact
      attrs.merge({"product_ids" => product_ids})
    end

    def find_or_create(news_trades,&block)
      news_trades.each do |trade|
        conditions = {:name => trade.buyer_nick,:account_id => trade.account_id,:ec_name => trade._type }
        customer = Customer.find_or_create_by(conditions)
        transaction_histories           = customer.transaction_histories
        transaction_history             = transaction_histories.find_by(:tid => trade.tid) rescue customer.transaction_histories.build
        transaction_history.attributes  = transaction_history_attributes(trade)
        customers_attributes            = parse_attributes(trade)
        customer.update_attributes(customers_attributes)

        yield(trade) if block_given?
      end
    end

    def parse_attributes(trade)
      attrs = trade.attributes
      {"buyer_nick" => "name","buyer_email" => "email"}.each_pair do |k,v|
        attrs[v] = attrs.delete(k)
      end
      attrs.slice(*customer_keys)
    end
  end
end