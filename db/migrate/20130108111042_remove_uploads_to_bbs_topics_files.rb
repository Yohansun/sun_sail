class RemoveUploadsToBbsTopicsFiles < ActiveRecord::Migration
  def change
  	remove_column :bbs_topics, :uploadfile_file_name
    remove_column :bbs_topics, :uploadfile_content_type
    remove_column :bbs_topics, :uploadfile_file_size
    remove_column :bbs_topics, :uploadfile_updated_at
  end
end
