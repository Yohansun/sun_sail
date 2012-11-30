class CreateTaobaoTradeRates < ActiveRecord::Migration
  def change	
  create_table :taobao_trade_rates do |t|
      t.string :tid
      t.string :oid
      t.string :role
      t.string :nick
      t.text :result
      t.datetime :created
      t.string :rated_nick
      t.string :item_title
      t.float :item_price
      t.string :content
      t.string :reply
      t.timestamps
    end
    
    add_index :taobao_trade_rates, :tid
    add_index :taobao_trade_rates, :oid
  end
end
