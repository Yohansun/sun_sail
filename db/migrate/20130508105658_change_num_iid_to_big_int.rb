class ChangeNumIidToBigInt < ActiveRecord::Migration
  def change
  	change_column :taobao_products, :num_iid, :integer, :limit => 8
  end
end
