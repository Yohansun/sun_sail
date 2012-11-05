# -*- encoding : utf-8 -*-
class LogisticArea < ActiveRecord::Base
	attr_accessible :logistic_id, :area_id
  belongs_to :logistic
  belongs_to :area
end
