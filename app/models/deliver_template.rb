# == Schema Information
#
# Table name: deliver_templates
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  xml        :string(255)
#  image      :string(255)
#  account_id :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class DeliverTemplate < ActiveRecord::Base
  attr_protected []
  mount_uploader :xml,   DeliverXmlUploader
  mount_uploader :image, DeliverImageUploader
  belongs_to :account
end
