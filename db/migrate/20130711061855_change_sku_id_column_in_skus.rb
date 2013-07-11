class ChangeSkuIdColumnInSkus < ActiveRecord::Migration
  def change
    change_column :skus, :sku_id, :string
  end
end
