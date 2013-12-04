class RenameLogisticsColumnXml < ActiveRecord::Migration
  def change
    rename_column :logistics, :xml, :print_image
  end
end