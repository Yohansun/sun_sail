class AddTradeTypeToTradeSources < ActiveRecord::Migration
  def change
    add_column :trade_sources, :trade_type, :string
  end
end
