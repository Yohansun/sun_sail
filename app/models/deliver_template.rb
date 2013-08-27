class DeliverTemplate < ActiveRecord::Base
  attr_protected []
  mount_uploader :xml,   DeliverXmlUploader
  mount_uploader :image, DeliverImageUploader
  belongs_to :account
end