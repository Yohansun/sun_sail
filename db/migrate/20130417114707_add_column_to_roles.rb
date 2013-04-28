class AddColumnToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :account_id,:integer,:null => false
  end
end
