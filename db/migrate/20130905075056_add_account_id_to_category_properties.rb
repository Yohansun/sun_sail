class AddAccountIdToCategoryProperties < ActiveRecord::Migration
  def change
    add_column :category_properties, :account_id, :integer
  end
end
