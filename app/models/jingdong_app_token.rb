# encoding : utf-8 -*-
# == Schema Information
#
# Table name: jingdong_app_tokens
#
#  id                 :integer(4)      not null, primary key
#  account_id         :integer(4)
#  access_token       :string(255)
#  refresh_token      :string(255)
#  jingdong_user_id   :string(255)
#  jingdong_user_nick :string(255)
#  trade_source_id    :integer(4)
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#

class JingdongAppToken < ActiveRecord::Base
  belongs_to :account
  belongs_to :trade_source

  attr_accessible :trade_source_id, :jingdong_user_id, :jingdong_user_nick, :account_id, :access_token, :refresh_token

  # validates :jingdong_user_id, :jingdong_user_nick, presence: true, uniqueness: true

end
