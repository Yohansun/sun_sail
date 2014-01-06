class AddEnabledCheckerToTradeSources < ActiveRecord::Migration
  def change
    add_column :trade_sources, :enabled_checker, :boolean,:default => false
  end
end
