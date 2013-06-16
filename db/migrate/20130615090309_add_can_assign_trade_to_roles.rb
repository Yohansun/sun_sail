class AddCanAssignTradeToRoles < ActiveRecord::Migration
  def change
    add_column  :roles,  :can_assign_trade,  :boolean
    add_column  :users,  :can_assign_trade,  :boolean
    add_column  :users,  :trade_percent,  :integer
  end
end