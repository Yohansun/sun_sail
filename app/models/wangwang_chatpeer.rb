class WangwangChatpeer
  include Mongoid::Document  
  field :user_id,    type: String
  field :uid,        type: String
  field :buyer_nick, type: String
  field :date,       type: DateTime

end