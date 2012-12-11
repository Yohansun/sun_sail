class WangwangChatlog
  include Mongoid::Document
  
  field :user_id,    type: String
  field :buyer_nick, type: String
  field :content,    type: String
  field :direction,  type: String
  field :time,       type: DateTime

end