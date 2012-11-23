class WangwangChatlog
  include Mongoid::Document
  
  field :from_id,    type: String
  field :to_id,      type: String
  field :content,    type: String
  field :direction,  type: String
  field :time,       type: DateTime

end