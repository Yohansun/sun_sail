# -*- encoding : utf-8 -*-
class OnsiteServiceArea < ActiveRecord::Base
  attr_accessible :account_id, :area_id
  belongs_to :account
  belongs_to :area
end
