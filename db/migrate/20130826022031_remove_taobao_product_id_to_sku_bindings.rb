class RemoveTaobaoProductIdToSkuBindings < ActiveRecord::Migration
  def up
    remove_column :sku_bindings,:taobao_sku_id
  end

  def down
    add_column :sku_bindings,:taobao_product_id,:integer
  end
end
