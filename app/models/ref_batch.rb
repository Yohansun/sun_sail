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

  def change_ref_orders(orders)
    ref_orders.delete_all
    orders.each do |order|
      order_array = order.split(",")
      new_order = ref_orders.create()
      new_order.sku_id = order_array[0]
      new_order.title = order_array[1]
      new_order.num = order_array[2]
    end
  end

  def add_ref_log(current_user, memo)
    new_log = ref_logs.create()
    new_log.operation = operation_text
    new_log.operator = current_user.name
    new_log.operator_id = current_user.id
    new_log.log_memo = memo
    new_log.operated_at = Time.now
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
    end
  end

end