class AddTimestampsToTaobaoSkus < ActiveRecord::Migration
  def change
    add_column :taobao_skus, :created_at, :datetime
    add_column :taobao_skus, :updated_at, :datetime
  end
end
