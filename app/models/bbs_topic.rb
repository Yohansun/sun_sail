# == Schema Information
#
# Table name: bbs_topics
#
#  id              :integer(4)      not null, primary key
#  bbs_category_id :integer(4)
#  user_id         :integer(4)
#  title           :string(255)
#  read_count      :integer(4)      default(0)
#  download_count  :integer(4)      default(0)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

class BbsTopic < ActiveRecord::Base
  # attr_accessible :title, :body

  scope :hot, order("download_count DESC")
  scope :latest, order("created_at DESC")

end
