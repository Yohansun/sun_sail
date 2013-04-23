class AddAccountIdToSkus < ActiveRecord::Migration
  def change
  	add_column :skus, :account_id, :integer
  	add_column :taobao_skus, :account_id, :integer
  end
end
