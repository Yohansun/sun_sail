class AddBbsTopicIdToUploadFiles < ActiveRecord::Migration
  def change
  	add_column :upload_files, :bbs_topic_id, :integer
  end
end
