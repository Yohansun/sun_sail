class AddParentIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :parent_id, :integer
    add_column :products, :lft, :integer, default: 0
    add_column :products, :rgt, :integer, default: 0
  end
end
