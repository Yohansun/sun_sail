# == Schema Information
#
# Table name: bbs_topics
#
#  id                      :integer(4)      not null, primary key
#  bbs_category_id         :integer(4)
#  user_id                 :integer(4)
#  title                   :string(255)
#  body                    :text
#  read_count              :integer(4)      default(0)
#  download_count          :integer(4)      default(0)
#  created_at              :datetime        not null
#  updated_at              :datetime        not null
#  uploadfile_file_name    :string(255)
#  uploadfile_content_type :string(255)
#  uploadfile_file_size    :integer(4)
#  uploadfile_updated_at   :datetime
#

class BbsTopic < ActiveRecord::Base
  attr_accessible :bbs_category, :title, :body, :user, :bbs_category_id, :uploadfile, :uploadfile_file_name, :uploadfile_content_type, :uploadfile_file_size, :uploadfile_updated_at
  has_attached_file :uploadfile,
                    :whiny_thumbnails => true,
                    :url => "/system/:class/:attachment/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/system/:class/:attachment/:id/:style/:basename.:extension"

  belongs_to :bbs_category
  belongs_to :user

  scope :hot, order("read_count DESC")
  scope :latest, order("created_at DESC")

  validates :title, :body, presence: true

end
