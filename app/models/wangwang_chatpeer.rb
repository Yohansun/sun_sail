class WangwangChatpeer
  include Mongoid::Document
  field :account_id, type: Integer 
  field :user_id,    type: String
  field :buyer_nick, type: String
  field :date,       type: Integer
end