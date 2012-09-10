class AddThreeColumnsToTradeSources < ActiveRecord::Migration
  def change
  	add_column :trade_sources, :fetch_quantity, :integer, default: 20
    add_column :trade_sources, :fetch_time_circle, :integer, default: 15
    add_column :trade_sources, :high_pressure_valve, :Boolean, default: false
  end
end
