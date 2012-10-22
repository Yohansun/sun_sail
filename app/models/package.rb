class Package < ActiveRecord::Base
  attr_accessible :iid, :number

  belongs_to :product
end
