# == Schema Information
#
# Table name: upload_files
#
#  id                :integer(4)      not null, primary key
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer(4)
#  file_updated_at   :datetime
#

class UploadFile < ActiveRecord::Base
  belongs_to :bbs_topic
  attr_accessible :bbs_topic_id, :file
  has_attached_file :file,
                    :whiny_thumbnails => true,
                    :url => "/system/:class/:attachment/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/system/:class/:attachment/:id/:style/:basename.:extension"
end
