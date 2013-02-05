class RemoveAccountIdFromPackage < ActiveRecord::Migration
  def up
    remove_column :packages, :account_id
  end

  def down
    add_column :packages, :account_id, :integer
  end
end
