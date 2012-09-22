# -*- encoding : utf-8 -*-

class SellersArea < ActiveRecord::Base
  belongs_to :seller
  belongs_to :area
end