class AddGoodTypeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :good_type, :integer
  end
end
