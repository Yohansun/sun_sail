class AddBbsTopicIdToUplaodFiles < ActiveRecord::Migration
  def change
    add_column :uplaod_files, :bbs_topic_id, :integer
  end
end
