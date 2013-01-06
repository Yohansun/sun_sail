class CreateAlipayTradeHistories < ActiveRecord::Migration
  def change
    create_table :alipay_trade_histories do |t|
      t.string  :finance_trade_sn
      t.string  :business_trade_sn
      t.string  :merchant_trade_sn
      t.string  :product_name
      t.datetime :traded_at
      t.string  :account_info
      t.decimal :revenue_amount
      t.decimal :outlay_amount
      t.decimal :balance_amount
      t.string  :trade_source
      t.string  :trade_type
      t.string  :memo, limit: 500
      t.timestamps
    end
    add_index :alipay_trade_histories, :trade_type
  end
end
