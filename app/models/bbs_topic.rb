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
#

class BbsTopic < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :bbs_category_id, :title, :body

  belongs_to :bbs_category
  belongs_to :user

  scope :hot, order("download_count DESC")
  scope :latest, order("created_at DESC")

  validates :title, :body, presence: true

end
