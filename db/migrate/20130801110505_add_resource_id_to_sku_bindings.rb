class AddResourceIdToSkuBindings < ActiveRecord::Migration
  def change
    add_column :sku_bindings,:resource_id,:integer
    add_column :sku_bindings,:resource_type,:integer
    SkuBinding.update_all("resource_id = taobao_sku_id, resource_type = 'TaobaoSku'")
  end
end