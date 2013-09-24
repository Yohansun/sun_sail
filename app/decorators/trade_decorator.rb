# -*- encoding : utf-8 -*-
class TradeDecorator < Draper::Base
  decorates :trade

  def pay_time
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.pay_time
      when 'TaobaoTrade','CustomTrade','Trade','YihaodianTrade'
        trade.pay_time
      when 'JingdongTrade'
        trade.pay_time
    end
  end

  def consign_time
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.consign_time || trade.delivered_at
      when 'TaobaoTrade','CustomTrade','Trade','JingdongTrade','YihaodianTrade'
        trade.consign_time
    end
  end

  def status_text
    case trade._type
      when 'TaobaoPurchaseOrder'
        fenxiao_status_text
      when 'TaobaoTrade','CustomTrade','Trade'
        taobao_order_status_text
      when 'JingdongTrade','YihaodianTrade'
        trade.status_name
    end
  end

  def receiver_name
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.receiver['name']
      when 'TaobaoTrade','CustomTrade','Trade','JingdongTrade','YihaodianTrade'
        trade.receiver_name
    end
  end

  def receiver_mobile_phone
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.receiver['mobile_phone']
      when 'TaobaoTrade','CustomTrade','Trade','JingdongTrade','YihaodianTrade'
        trade.receiver_mobile
    end
  end

  def receiver_phone
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.receiver['phone']
      when 'TaobaoTrade','CustomTrade','Trade','JingdongTrade','YihaodianTrade'
        trade.receiver_phone
    end
  end

  def interface_name
    trade.seller.try(:parent).try(:name)
  end

  def interface_mobile
    trade.seller.try(:parent).try(:mobile)
  end

  def receiver_full_address
    "#{self.receiver_state} #{self.receiver_city} #{self.receiver_district} #{self.receiver_address}"
  end

  def receiver_area_name
    "#{self.receiver_state} #{self.receiver_city} #{self.receiver_district}"
  end

  def has_wrong_arguments_address?
    self.receiver_state.blank? || self.receiver_city.blank? || self.receiver_district.blank? || self.receiver_address.blank?
  end

  def receiver_address
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.receiver['address']
      when 'TaobaoTrade','CustomTrade','Trade','YihaodianTrade'
        trade.receiver_address
      when 'JingdongTrade'
        trade.receiver_address.try(:delete, self.receiver_state).try(:delete, self.receiver_city).try(:delete, self.receiver_district)
    end
  end

  def receiver_district
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.receiver['district']
      when 'TaobaoTrade','CustomTrade','Trade','JingdongTrade','YihaodianTrade'
        trade.receiver_district
    end
  end

  def receiver_city
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.receiver['city']
      when 'TaobaoTrade','CustomTrade','Trade','JingdongTrade','YihaodianTrade'
        trade.receiver_city
    end
  end

  def receiver_state
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.receiver['state']
      when 'TaobaoTrade','CustomTrade','Trade','JingdongTrade','YihaodianTrade'
        trade.receiver_state
    end
  end

  def receiver_zip
    case trade._type
      when 'TaobaoPurchaseOrder'
        trade.receiver['zip']
      when 'TaobaoTrade','CustomTrade','Trade','YihaodianTrade'
        trade.receiver_zip
      when 'JingdongTrade'
        ''
    end
  end

  #TaobaoPurchaseOrder doesn't have seller_disount
  def seller_discount
    case trade._type
    when 'TaobaoTrade','CustomTrade','Trade'
      discount = trade.promotion_fee
    when 'JingdongTrade'
      discount = trade.seller_discount
    when 'YihaodianTrade'
      0.0
    end
    discount ||= 0.0
  end

  def distributor_payment
    case trade._type
    when 'TaobaoPurchaseOrder'
      trade.distributor_payment
    end
  end

  def total_fee
    trade.payment
  end

  def point_fee
    case trade._type
    when 'TaobaoPurchaseOrder'
      0.0
    when 'TaobaoTrade','CustomTrade','Trade'
      trade.point_fee
    when 'JingdongTrade','YihaodianTrade'
      0.0
    end
  end

  #总价
  def sum_fee
    case trade._type
    when 'TaobaoPurchaseOrder'
      trade.orders_total_fee
    when 'TaobaoTrade','CustomTrade','Trade','JingdongTrade','YihaodianTrade'
      trade.total_fee
    end
  end

  def buyer_message
    case trade._type
    when 'TaobaoPurchaseOrder'
      trade.memo
    when 'TaobaoTrade','CustomTrade','Trade','JingdongTrade','YihaodianTrade'
      trade.buyer_message
    end
  end

  def buyer_nick
    case trade._type
    when 'TaobaoPurchaseOrder'
      trade.buyer_nick
    when 'TaobaoTrade','CustomTrade','Trade'
      trade.buyer_nick
    when 'JingdongTrade','YihaodianTrade'
    end
  end

  def seller_memo
    case trade._type
    when 'TaobaoPurchaseOrder'
      trade.supplier_memo
    when 'TaobaoTrade','CustomTrade','Trade','JingdongTrade','YihaodianTrade'
      trade.seller_memo
    # when 'JingdongTrade'
    #   [trade.pay_type, trade.delivery_type, trade.invoice_info].join("; ")
    end
  end

  def trade_source
    case trade._type
    when 'TaobaoPurchaseOrder'
      '分销平台'
    when 'TaobaoTrade'
      '淘宝'
    when 'CustomTrade'
      if trade.custom_type == 'gift_trade'
        '赠品'
      elsif trade.custom_type == 'handmade_trade'
        '人工'
      end
    when 'JingdongTrade'
      '京东'
    when 'YihaodianTrade'
      '一号店'
    else
      if trade.merged_trade_ids.present?
        type_array = Trade.deleted.where(:_id.in => trade.merged_trade_ids).only(:_type).map(&:_type).uniq
        if type_array.count > 1
          '合并(淘宝＋人工)'
        else
          if type_array[0] == "TaobaoTrade"
            '合并(淘宝)'
          else
            '合并(人工)'
          end
        end
      end
    end
  end

  def orders
    case trade._type
    when 'TaobaoPurchaseOrder'
      trade.taobao_sub_purchase_orders
    when 'TaobaoTrade','CustomTrade','Trade'
      trade.taobao_orders
    when 'JingdongTrade'
      trade.jingdong_orders
    when 'YihaodianTrade'
      trade.yihaodian_orders
    end
  end

  def is_1568
    if trade.try(:seller).try(:areas).try(:first).nil?
      false
    else
      trade.seller.areas.first.is_1568
    end
  end

  def can_auto_dispatch
    case trade._type
    when 'TaobaoTrade'
      trade.status == "WAIT_SELLER_SEND_GOODS" && trade.auto_dispatchable?
    else
      false
    end
  end

  protected

  def fenxiao_status_text
    case trade.status
    when 'WAIT_BUYER_PAY'
      '等待付款'
    when 'WAIT_SELLER_SEND_GOODS'
      '已付款,待发货'
    when 'WAIT_BUYER_CONFIRM_GOODS'
      '已付款,已发货'
    when 'TRADE_FINISHED'
      '交易成功'
    when 'TRADE_CLOSED'
      '交易已关闭'
    when 'WAIT_BUYER_CONFIRM_GOODS_ACOUNTED'
      '已付款（已分账）,已发货'
    when 'WAIT_SELLER_SEND_GOODS_ACOUNTED'
      '已付款（已分账）,待发货'
    when 'TRADE_REFUNDED'
      '已退款'
    when 'TRADE_REFUNDING'
      '退款中'
    else
      trade.status
    end
  end

  def taobao_order_status_text
    if trade.return_ref_status.present?
      trade.return_ref_status
    elsif trade.refund_ref_status.present?
      trade.refund_ref_status
    else
      case trade.status
      when "TRADE_NO_CREATE_PAY", "WAIT_BUYER_PAY", "ALL_WAIT_PAY"
        "等待付款"
      when "WAIT_SELLER_SEND_GOODS"
        if trade.seller_id
          if trade.logistic_waybill
            if trade.is_auto_dispatch == true
              "已设置物流,待发货,自动分派"
            elsif trade.is_auto_dispatch == false
              "已设置物流,待发货,手动分派"
            end
          else
            if trade.is_auto_dispatch == true
              if trade.fetch_account.settings.enable_module_third_party_stock == 1
                "已分派,#{trade.stock_out_bill.try(:status_text) || '出库单已关闭'},自动分派"
              else
                "已分派,待设置物流,自动分派"
              end
            elsif trade.is_auto_dispatch == false
              if trade.fetch_account.settings.enable_module_third_party_stock == 1
                "已分派,#{trade.stock_out_bill.try(:status_text) || '出库单已关闭'},手动分派"
              else
                "已分派,待设置物流,手动分派"
              end
            end
          end
        else
          "已付款,待分派"
        end
      when "WAIT_BUYER_CONFIRM_GOODS", "TRADE_BUYER_SIGNED"
        if trade.seller_confirm_deliver_at
          if trade.is_auto_deliver == true && trade.is_auto_dispatch == true
            "已付款,已发货, 自动发货, 自动分派"
          elsif trade.is_auto_deliver == true && trade.is_auto_dispatch == false
            "已付款,已发货, 手动发货, 自动分派"
          elsif trade.is_auto_deliver == false && trade.is_auto_dispatch == true
            "已付款,已发货, 自动发货, 手动分派"
          else
            "已付款,已发货, 手动发货, 手动分派"
          end
        else
          if trade.is_auto_deliver == true && trade.is_auto_dispatch == true
            "已发货,待确认发货,自动发货, 自动分派"
          elsif trade.is_auto_deliver == false && trade.is_auto_dispatch == true
            "已发货,待确认发货,手动发货, 自动分派"
          elsif trade.is_auto_deliver == true && trade.is_auto_dispatch == false
            "已发货,待确认发货,自动发货, 手动分派"
          else
            "已发货,待确认发货,手动发货, 手动分派"
          end
        end
      when "TRADE_FINISHED"
        "交易成功"
      when "TRADE_CLOSED","TRADE_CLOSED_BY_TAOBAO", "ALL_CLOSED"
        "交易关闭"
      else
        trade.status
      end
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
