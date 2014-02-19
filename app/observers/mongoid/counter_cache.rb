#encoding: utf-8
class CounterCache < Mongoid::Observer
  observe :trade,:deliver_bill

  def after_save(object)
    expire_trades(object.changes,object) if object.is_a?(Trade)
  end

  def after_destroy(object)
    expire_trades({},object)        if object.is_a?(Trade)
    expire_deliver_bills({},object) if object.is_a?(DeliverBill)
  end

  def after_create(object)
    expire_deliver_bills({},object) if object.is_a?(DeliverBill)
  end

  def expire_caches(*args)
    options = args.extract_options!
    Rails.logger
    args.each do |key|
      expire_cache(key,namespace: namespace(options[:account_id]))
    end
  end

  def expire_cache(key,options={})
    Rails.cache.delete(key,options)
  end

  def namespace(account_id)
    "counter_caches/#{account_id}"
  end

  def expire_trades(previous_changes,object)
    expire_caches("trades/all"          ,account_id: object.account_id)                                           if previous_changes["news"].present?
    expire_caches("trades/undispatched","trades/undelivered","trades/delivered",account_id: object.account_id)    if previous_changes["status"].present?

    expire_caches("trades/undispatched","trades/undelivered","trades/delivered",account_id: object.account_id)    if previous_changes["has_unusual_state"].present?

    expire_caches("trades/undispatched" ,account_id: object.account_id)                                           if previous_changes["seller_id"].present? || previous_changes["pay_time"].present?
    expire_caches("trades/undelivered"  ,account_id: object.account_id)                                           if previous_changes["dispatched_at"].present?
    expire_caches("trades/unusual_all"  ,account_id: object.account_id)                                           if object.unusual_states.map(&:changes).any? {|u| u["repaired_at"].present?}
    expire_caches("trades/locked"       ,account_id: object.account_id)                                           if previous_changes["is_locked"].present?

    # expire all of trades counter cache
    expire_caches("trades/all","trades/undispatched","trades/undelivered","trades/delivered","trades/unusual_all","trades/locked",account_id: object.account_id) if object.deleted?
  end

  def expire_deliver_bills(attrs,object)
    expire_caches("deliver_bills/all","logistic_bills/all",account_id: object.account_id)
  end
end