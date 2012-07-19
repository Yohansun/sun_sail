class AddTreeColumnsToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :parent_id, :integer
    add_column :sellers, :lft, :integer
    add_column :sellers, :rgt, :integer
  end
end
