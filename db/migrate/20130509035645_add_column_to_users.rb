class AddColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :superadmin, :boolean,:default => 0, :null => false
  end
end
