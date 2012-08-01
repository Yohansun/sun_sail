class AddUserIdToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :user_id, :integer
  end
end
