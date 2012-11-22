class AddUpdatedAtToProducts < ActiveRecord::Migration
  def change
    add_column :products, :updated_at, :datetime
    add_column :products, :created_at, :datetime

    Product.update_all(created_at: Time.now, updated_at: Time.now)
  end
end
