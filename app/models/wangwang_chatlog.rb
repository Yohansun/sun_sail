class WangwangChatlog
  include Mongoid::Document
  
  field :user_id,    type: String
  field :buyer_nick, type: String
  field :start_time, type: DateTime
  field :end_time,   type: DateTime
  field :usable,     type: Boolean,  default: true

  embeds_many :wangwang_chatmsgs
end