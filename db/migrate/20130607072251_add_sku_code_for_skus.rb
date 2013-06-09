class AddSkuCodeForSkus < ActiveRecord::Migration
  def up
    add_column  :skus,  :code,  :string
  end

  def down
    remove_column  :skus,  :code
  end
end
