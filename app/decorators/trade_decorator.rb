# -*- encoding : utf-8 -*-
class TradeDecorator < Draper::Base
  decorates :trade

  def status
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.status
      when 'TaobaoTrade'
        trade.status
      when 'JingdongTrade'
        trade.order_state
    end
  end

  def created
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.created
      when 'TaobaoTrade'
        trade.created
      when 'JingdongTrade'
        trade.order_start_time
    end
  end

  def pay_time
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.pay_time
      when 'TaobaoTrade'
        trade.pay_time
      when 'JingdongTrade'
    end
  end

  def consign_time
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.consign_time || trade.delivered_at
      when 'TaobaoTrade'
        trade.consign_time
      when 'JingdongTrade'
        trade.order_end_time
    end
  end

  def status_text
    case trade._type
      when 'TaobaoPurchaseOrder'
        fenxiao_status_text
      when 'TaobaoTrade'
        taobao_order_status_text
      when 'JingdongTrade'
        jingdong_order_status_text
    end
  end

  def receiver_name
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.receiver['name']
      when 'TaobaoTrade'
        trade.receiver_name
      when 'JingdongTrade'
        trade.consignee_info['fullname']
    end
  end

  def receiver_mobile_phone
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.receiver['mobile_phone']
      when 'TaobaoTrade'
        trade.receiver_mobile
      when 'JingdongTrade'
        trade.consignee_info['mobile']
    end
  end

  def receiver_phone
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.receiver['phone']
      when 'TaobaoTrade'
        trade.receiver_phone
      when 'JingdongTrade'
        trade.consignee_info['telephone']
    end
  end

  def receiver_address
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.receiver['address']
      when 'TaobaoTrade'
        trade.receiver_address
      when 'JingdongTrade'
        trade.consignee_info['full_address']
    end
  end

  def receiver_district
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.receiver['district']
      when 'TaobaoTrade'
        trade.receiver_district
      when 'JingdongTrade'
        trade.consignee_info['county']
    end
  end

  def receiver_city
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.receiver['city']
      when 'TaobaoTrade'
        trade.receiver_city
      when 'JingdongTrade'
        trade.consignee_info['city']
    end
  end

  def receiver_state
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.receiver['state']
      when 'TaobaoTrade'
        trade.receiver_state
      when 'JingdongTrade'
        trade.consignee_info['province']
    end
  end

  def receiver_zip
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.receiver['zip']
      when 'TaobaoTrade'
        trade.receiver_zip
      when 'JingdongTrade'
        ''
    end
  end

  def post_fee
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.post_fee
      when 'TaobaoTrade'
        trade.post_fee
      when 'JingdongTrade'
        unless trade.freight_price.blank?
          trade.freight_price
        else
          0
        end
    end
  end

  def seller_discount
    case trade._type
      when 'TaobaoPurchaseOrder'
        0
      when 'TaobaoTrade'
        0
      when 'JingdongTrade'
       trade.seller_discount
    end
  end    

  def total_fee
    case trade._type
      when 'TaobaoPurchaseOrder'
        self.sum_fee.to_f + self.post_fee.to_f
      when 'TaobaoTrade'
        trade.payment
      when 'JingdongTrade'
        trade.order_seller_price
    end
  end
 
 #总价
  def sum_fee
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.orders.inject(0) { |sum, order| sum + order.buyer_payment.to_f }
      else  
        self.total_fee.to_f + self.seller_discount.to_f - self.post_fee.to_f
      end  
  end
  
  def buyer_message
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.memo
      when 'TaobaoTrade'
        trade.buyer_message
      when 'JingdongTrade'
        trade.order_remark
    end
  end

  def seller_memo
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.supplier_memo
      when 'TaobaoTrade'
        trade.seller_memo
      when 'JingdongTrade'
        [trade.pay_type, trade.delivery_type, trade.invoice_info].join("; ")
    end
  end

  def trade_source
    case trade._type
      when 'TaobaoPurchaseOrder'
        '分销平台'
      when 'TaobaoTrade'
        '淘宝'
      when 'JingdongTrade'
        '京东'
    end
  end

  def orders
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.taobao_sub_purchase_orders
      when 'TaobaoTrade'
        trade.taobao_orders
      when 'JingdongTrade'
        trade.jingdong_orders
    end
  end
  
  def is_1568
    if trade.try(:seller).try(:areas).try(:first).nil?
      false
    else
      trade.seller.areas.first.is_1568
    end
  end  

  protected

  def fenxiao_status_text
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
        '交易已关闭'
      when 'WAIT_BUYER_CONFIRM_GOODS_ACOUNTED'
        '已付款（已分账），已发货'
      when 'WAIT_SELLER_SEND_GOODS_ACOUNTED'
        '已付款（已分账），待发货'
      when 'TRADE_REFUNDING'
        '退款中'
      else
        trade.status
    end
  end


  def taobao_order_status_text
    case trade.status
      when 'WAIT_BUYER_PAY'
        '等待付款'
      when 'WAIT_SELLER_SEND_GOODS'
        '已付款，待发货'
      when 'WAIT_BUYER_CONFIRM_GOODS'
        '已付款，已发货'
      when 'TRADE_CLOSED_BY_TAOBAO'
        '交易被淘宝关闭'
      when 'TRADE_FINISHED'
        '交易成功'
      when 'TRADE_CLOSED'
        '交易已关闭'
      else
        trade.status
    end
  end

  def jingdong_order_status_text
    case trade.order_state
      when 'WAIT_SELLER_DELIVERY'
        '已付款，待发货'
      when 'WAIT_SELLER_STOCK_OUT'
        '已付款，待发货'
      when 'WAIT_GOODS_RECEIVE_CONFIRM'
        '已付款，已发货'
      when 'FINISHED_L'
        '交易成功'
      when 'TRADE_CANCELED'
        '交易已关闭'
      else
        trade.order_state
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
