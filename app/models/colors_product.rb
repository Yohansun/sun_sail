# -*- encoding : utf-8 -*-
class ColorsProduct < ActiveRecord::Base
  belongs_to :color
  belongs_to :product
end
