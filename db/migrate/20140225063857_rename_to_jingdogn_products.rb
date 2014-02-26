class RenameToJingdognProducts < ActiveRecord::Migration
  def up
    change_column :jingdong_products,:attribute_s,:text
  end

  def down
    change_column :jingdong_products,:attribute_s,:string
  end
end
