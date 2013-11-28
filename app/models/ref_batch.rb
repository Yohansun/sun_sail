# -*- encoding : utf-8 -*-
class RefBatch
  include Mongoid::Document
  include Mongoid::Timestamps

  field :ref_type,        type: String
  field :batch_num,       type: Integer
  field :status,          type: String
  field :ref_payment,     type: Float

  embedded_in :trades
  embeds_many :ref_logs
  embeds_many :ref_orders

  def self.find_batch(ref_type)
    where(ref_type: ref_type).last
  end

  def change_ref_orders(orders)
    ref_orders.delete_all
    orders.each do |order|
      order_array = order.split(",")
      new_order = ref_orders.create(
        sku_id: order_array[0],
        title:  order_array[1],
        num:    order_array[2]
      )
    end
  end

  def add_ref_log(current_user, memo)
    new_log = ref_logs.create(
      operated_at: Time.now,
      operation:   operation_text,
      operator:    current_user.name,
      operator_id: current_user.id,
      log_memo:    memo
    )
  end

  def change_status(current_user, changed_status, memo)
    update_attributes(status: changed_status)
    add_ref_log(current_user, memo)
    if ['cancel_refund_ref','cancel_return_ref'].include?(changed_status)
      ref_orders.delete_all
    end
  end

  def operation_text
    case status
    when 'request_add_ref'
      '申请补货'
    when 'confirm_add_ref'
      '确认补货'
    when 'request_return_ref'
      '申请退货'
    when 'confirm_return_ref'
      '确认退货'
    when 'return_ref_money'
      '确认退款'
    when 'cancel_return_ref'
      '取消退货'
    when 'request_refund_ref'
      '申请线下退款'
    when 'confirm_refund_ref'
      '确认线下退款'
    when 'cancel_refund_ref'
      '取消线下退款'
    end
  end

end