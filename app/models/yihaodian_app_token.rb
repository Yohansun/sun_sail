# encoding : utf-8 -*-
# == Schema Information
#
# Table name: yihaodian_app_tokens
#
#  id                  :integer(4)      not null, primary key
#  account_id          :integer(4)
#  access_token        :string(255)
#  refresh_token       :string(255)
#  yihaodian_user_id   :integer(4)
#  yihaodian_user_nick :string(255)
#  trade_source_id     :integer(4)
#  isv_id              :integer(4)
#  merchant_id         :integer(4)
#  user_code           :string(255)
#  user_type           :integer(4)
#  created_at          :datetime        not null
#  updated_at          :datetime        not null
#

class YihaodianAppToken < ActiveRecord::Base
  act_as_cached
  belongs_to :account
  belongs_to :trade_source

  attr_protected []
end
