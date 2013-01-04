class AddAttachmentUploadfileToBbsTopics < ActiveRecord::Migration
  def self.up
    add_column :bbs_topics, :uploadfile_file_name, :string
    add_column :bbs_topics, :uploadfile_content_type, :string
    add_column :bbs_topics, :uploadfile_file_size, :integer
    add_column :bbs_topics, :uploadfile_updated_at, :datetime
  end

  def self.down
    remove_column :bbs_topics, :uploadfile_file_name
    remove_column :bbs_topics, :uploadfile_content_type
    remove_column :bbs_topics, :uploadfile_file_size
    remove_column :bbs_topics, :uploadfile_updated_at
  end
end
