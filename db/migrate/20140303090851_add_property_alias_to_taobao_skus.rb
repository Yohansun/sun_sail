class AddPropertyAliasToTaobaoSkus < ActiveRecord::Migration
  def change
    add_column :taobao_skus,:property_alias,:string
  end
end
