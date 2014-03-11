# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: logistic_areas
#
#  id                :integer(4)      not null, primary key
#  logistic_id       :integer(4)
#  area_id           :integer(4)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  account_id        :integer(4)
#  basic_post_weight :float
#  extra_post_weight :float
#  basic_post_fee    :float
#  extra_post_fee    :float
#

class LogisticArea < ActiveRecord::Base
  attr_accessible :logistic_id,
                  :area_id,
                  :account_id,
                  :basic_post_weight,
                  :basic_post_fee,
                  :extra_post_weight,
                  :extra_post_fee
  belongs_to :account
  belongs_to :logistic
  belongs_to :area

  after_create :set_account_id

  def has_full_post_fee_info
    basic_post_weight.present? &&
    basic_post_fee.present?    &&
    extra_post_weight.present? &&
    extra_post_fee.present?
  end


  private

  def set_account_id
    self.update_attributes(account_id: logistic.try(:account_id))
  end

end
