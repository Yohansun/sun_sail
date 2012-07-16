# -*- encoding : utf-8 -*-
class TradeDecorator < Draper::Base
  decorates :trade

  def tid
    case trade._type
    when 'TaobaoPurchaseOrder'
      trade.fenxiao_id
    else
      trade.tid
    end
  end

  def status
    case trade._type
    when 'TaobaoPurchaseOrder'
      fenxiao_status
    else
      trade.status
    end
  end

  def trade_source
    case trade._type
    when 'TaobaoPurchaseOrder'
      '分销平台'
    when 'TaobaoTrade'
      '淘宝'
    end
  end

  def orders
    case trade._type
    when 'TaobaoPurchaseOrder'
      trade.taobao_sub_purchase_orders
    else
      []
    end
  end


  protected
  def fenxiao_status
    case trade.status
    when 'WAIT_BUYER_PAY'
      '等待付款'
    when 'WAIT_SELLER_SEND_GOODS'
      '已付款，待发货'
    when 'WAIT_BUYER_CONFIRM_GOODS'
      '已付款，已发货'
    when 'TRADE_FINISHED'
      '交易成功'
    when 'TRADE_CLOSED'
      '交易关闭'
    when 'WAIT_BUYER_CONFIRM_GOODS_ACOUNTED'
      '已付款（已分账），已发货'
    when 'WAIT_SELLER_SEND_GOODS_ACOUNTED'
      '已付款（已分账），待发货'
    end
  end

  # Accessing Helpers
  #   You can access any helper via a proxy
  #
  #   Normal Usage: helpers.number_to_currency(2)
  #   Abbreviated : h.number_to_currency(2)
  #
  #   Or, optionally enable "lazy helpers" by including this module:
  #     include Draper::LazyHelpers
  #   Then use the helpers with no proxy:
  #     number_to_currency(2)

  # Defining an Interface
  #   Control access to the wrapped subject's methods using one of the following:
  #
  #   To allow only the listed methods (whitelist):
  #     allows :method1, :method2
  #
  #   To allow everything except the listed methods (blacklist):
  #     denies :method1, :method2

  # Presentation Methods
  #   Define your own instance methods, even overriding accessors
  #   generated by ActiveRecord:
  #
  #   def created_at
  #     h.content_tag :span, time.strftime("%a %m/%d/%y"),
  #                   :class => 'timestamp'
  #   end
end
