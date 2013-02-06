class RemoveAccountIdFromSettings < ActiveRecord::Migration
  def up
    remove_column :settings, :account_id
  end

  def down
    add_column :settings, :account_id, :integer
  end
end
