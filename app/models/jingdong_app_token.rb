# encoding : utf-8 -*-

class JingdongAppToken < ActiveRecord::Base
  belongs_to :account
  belongs_to :trade_source

  attr_accessible :trade_source_id, :jingdong_user_id, :jingdong_user_nick, :account_id, :access_token, :refresh_token

  # validates :jingdong_user_id, :jingdong_user_nick, presence: true, uniqueness: true

end