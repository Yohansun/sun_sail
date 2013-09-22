class CreateStockCsvFiles < ActiveRecord::Migration
  def change
    create_table :stock_csv_files do |t|
      t.string  :path               #文件存储路径
      t.integer :upload_user_id     #上传用户的用户ID
      t.string  :stock_in_bill_id   #关联入库单ID
      t.boolean :used               #关联入库单是否审核通过
      t.integer :seller_id          #关联仓库的seller_id

      t.timestamps
    end
  end
end
