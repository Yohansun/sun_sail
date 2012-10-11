class AddLogisticIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :logistic_id, :integer
  end
end
