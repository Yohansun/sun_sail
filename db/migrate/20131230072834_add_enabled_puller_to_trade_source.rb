class AddEnabledPullerToTradeSource < ActiveRecord::Migration
  def change
    add_column :trade_sources, :jushita_sync, :boolean,default: false
  end
end
