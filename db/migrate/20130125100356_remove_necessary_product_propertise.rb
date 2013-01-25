class RemoveNecessaryProductPropertise < ActiveRecord::Migration
  def change
    remove_column :products, :description
    remove_column :products, :technical_data
    remove_column :products, :status
    remove_column :products, :grade_id
    drop_table :grades
    add_column :products, :pic_url, :string
  end
end
