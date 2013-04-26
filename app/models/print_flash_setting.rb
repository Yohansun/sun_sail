class PrintFlashSetting < ActiveRecord::Base
  attr_accessible :xml_hash, :account_id, :logistic_id
  serialize :xml_hash, Hash

  belongs_to :logistic
  accepts_nested_attributes_for :logistic
end
