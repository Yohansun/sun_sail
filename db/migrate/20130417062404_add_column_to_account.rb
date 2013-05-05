class AddColumnToAccount < ActiveRecord::Migration
  def change
  	add_column :accounts, :seller_name, :string
  	add_column :accounts, :address, :string
  	add_column :accounts, :phone, :string
  	add_column :accounts, :deliver_bill_info, :string
  	add_column :accounts, :point_out, :string
  	add_column :accounts, :website, :string
  end
end
