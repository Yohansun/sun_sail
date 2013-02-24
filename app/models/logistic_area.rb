# == Schema Information
#
# Table name: logistic_areas
#
#  id          :integer(4)      not null, primary key
#  logistic_id :integer(4)
#  area_id     :integer(4)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  account_id  :integer(4)
#

# -*- encoding : utf-8 -*-
class LogisticArea < ActiveRecord::Base
  attr_accessible :logistic_id, :area_id, :account_id
  belongs_to :account
  belongs_to :logistic
  belongs_to :area
end
