# == Schema Information
#
# Table name: packages
#
#  id         :integer(4)      not null, primary key
#  iid        :string(255)
#  number     :integer(4)      default(1)
#  product_id :integer(4)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Package < ActiveRecord::Base
  attr_accessible :iid, :number

  belongs_to :product
end
