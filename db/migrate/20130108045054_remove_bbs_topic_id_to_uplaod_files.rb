class RemoveBbsTopicIdToUplaodFiles < ActiveRecord::Migration
  def up
    remove_column :uplaod_files, :quantity
  end

  def down
    add_column :uplaod_files, :quantity, :integer
  end
end
