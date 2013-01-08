class WangwangChatpeer
  include Mongoid::Document  
  field :user_id,    type: String
  field :buyer_nick, type: String
  field :date,       type: Integer
end