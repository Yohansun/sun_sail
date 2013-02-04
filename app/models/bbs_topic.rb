# == Schema Information
#
# Table name: bbs_topics
#
#  id              :integer(4)      not null, primary key
#  bbs_category_id :integer(4)
#  user_id         :integer(4)
#  title           :string(255)
#  body            :text
#  read_count      :integer(4)      default(0)
#  download_count  :integer(4)      default(0)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  account_id      :integer(4)
#

class BbsTopic < ActiveRecord::Base
  attr_accessible :bbs_category, :title, :body, :user, :bbs_category_id
  belongs_to :bbs_category
  belongs_to :user
  has_many :upload_files, :dependent => :destroy

  scope :hot, order("read_count DESC")
  scope :latest, order("created_at DESC")

  validates :title, :body, presence: true

end
