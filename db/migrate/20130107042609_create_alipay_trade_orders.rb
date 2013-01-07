class CreateAlipayTradeOrders < ActiveRecord::Migration
  def change
    create_table :alipay_trade_orders do |t|
      t.integer :alipay_trade_history_id
      t.string  :original_trade_sn
      t.string  :trade_sn
      t.datetime :traded_at
      t.timestamps
    end
    add_index :alipay_trade_orders, :alipay_trade_history_id
    add_index :alipay_trade_orders, :original_trade_sn
    add_index :alipay_trade_orders, :trade_sn
  end
end
