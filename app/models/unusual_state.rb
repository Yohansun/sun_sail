# -*- encoding : utf-8 -*-

class UnusualState
  include Mongoid::Document
  include Mongoid::Timestamps

  field :reason,         type: String
  field :key,            type: String
  field :note,           type: String
  field :text,           type: String

  field :reporter,       type: String
  field :reporter_role,  type: String
  field :repair_man,     type: String
  field :plan_repair_at, type: DateTime
  field :repaired_at,    type: DateTime
  field :created_at,     type: DateTime

  embedded_in :trade
  after_save do
     self.trade.update
     CounterCache.send(:new).expire_caches("trades/unusual_all",account_id: trade.try(:account_id)) if repaired_at_changed?
  end

  def add_key
  	case self.reason
  	  when "买家延迟发货"
  	  	"buyer_delay_deliver"
  	  when "卖家长时间未发货"
  	  	"seller_ignore_deliver"
  	  when "经销商缺货"
  	  	"seller_lack_product"
  	  when "经销商无法调色"
  	  	"seller_lack_color"
  	  when "买家要求退款"
  	  	"buyer_demand_refund"
  	  when "买家要求退货"
  	  	"buyer_demand_return_product"
  	  else
  	  	"other_unusual_state"
  	end
  end

  def unusual_color_class
    reporter_role.try('+', '_error')
  end

end