class AddProductIdToSkus < ActiveRecord::Migration
  def change
  	add_column :skus, :product_id, :integer
  end
end
