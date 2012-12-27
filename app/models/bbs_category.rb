# == Schema Information
#
# Table name: bbs_categories
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class BbsCategory < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :name

  has_many :topics
end
