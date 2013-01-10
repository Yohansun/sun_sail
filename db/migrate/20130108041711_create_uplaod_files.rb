class CreateUplaodFiles < ActiveRecord::Migration
  def change
    create_table :uplaod_files do |t|
      t.timestamps
    end
  end
end
