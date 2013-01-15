class RenameUploadFiles < ActiveRecord::Migration
  def change
  	rename_table :uplaod_files, :upload_files
  end
end
