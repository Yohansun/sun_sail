class AddAccountIdForModels < ActiveRecord::Migration

  def up
    add_column :products, :account_id, :integer
    add_column :categories, :account_id, :integer
    add_column :bbs_categories, :account_id, :integer
    add_column :bbs_topics, :account_id, :integer    
    add_column :colors,   :account_id, :integer
    add_column :packages,  :account_id, :integer
    add_column :sales,     :account_id, :integer
    add_column :sellers,   :account_id, :integer
    add_column :settings, :account_id, :integer
    add_column :stocks, :account_id, :integer
    create_table :accounts_users do |t|
      t.integer :account_id
      t.integer :user_id
    end    
  end

  def down
    remove_column :products, :account_id
    remove_column :categories, :account_id
    remove_column :bbs_categories, :account_id
    remove_column :bbs_topics, :account_id
    remove_column :colors,   :account_id
    remove_column :packages,  :account_id
    remove_column :sales,     :account_id
    remove_column :sellers,   :account_id
    remove_column :settings, :account_id
    remove_column :stocks, :account_id
    drop_table :accounts_users   
  end
end
