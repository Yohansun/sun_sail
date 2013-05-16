class AddColumnToSeller < ActiveRecord::Migration
  def change
    add_column :sellers, :stock_name,:string      #仓库名称
    add_column :sellers, :stock_user_id,:integer  #负责人 user_id
  end
end
