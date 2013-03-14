class CreateLogisticGroups < ActiveRecord::Migration
  def change
    create_table :logistic_groups do |t|
      t.integer :account_id
      t.string  :name
      t.integer :split_number
      t.timestamps
    end
    add_index :logistic_groups, :account_id
    add_column :products, :logistic_group_id, :integer
  end
end
