#encoding: utf-8
class CreateRefundOrders < ActiveRecord::Migration
  def change
    create_table :refund_orders do |t|
      t.integer :refund_product_id
      t.string  :title                                  #商品名称
      t.string  :num_iid
      t.decimal :refund_price ,default: 0.0             #退货金额
      t.integer :num          ,default: 0,  null: false #退货数量
      t.integer :sku_id
      t.string  :outer_id
      t.integer :stock_product_id
      t.integer :account_id
      t.string  :order_type
      t.integer :seller_id

      t.timestamps
    end
  end
end
