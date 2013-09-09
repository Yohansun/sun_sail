class AddTradeTypeToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :trade_type, :string, :default => 'Taobao'
  end
end
