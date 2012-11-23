class WangwangReplyState
  include Mongoid::Document
  field :user_id,    type: String
  field :reply_num,  type: Integer
  field :time,       type: DateTime
end