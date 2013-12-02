# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: print_flash_settings
#
#  id          :integer(4)      not null, primary key
#  xml_hash    :text
#  account_id  :integer(4)
#  logistic_id :integer(4)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class PrintFlashSetting < ActiveRecord::Base
  attr_accessible :xml_hash, :account_id, :logistic_id
  serialize :xml_hash, Hash

  belongs_to :logistic
  accepts_nested_attributes_for :logistic

  validate :is_xml_hash_a_hash

  private

  def is_xml_hash_a_hash
    errors.add(:xml_hash, "输入项不是合格的哈希值。") unless xml_hash.is_a?(Hash)
  end
end
