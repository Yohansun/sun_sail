class WangwangMemberContrast
  include Mongoid::Document
  
  field :user_id,                type: String
  field :created_at,             type: DateTime

  field :daily_reply_count,      type: Integer
  field :daily_inquired_count,   type: Integer
  field :daily_created_count,    type: Integer
  field :daily_created_payment,  type: Float
  field :daily_paid_count,       type: Integer
  field :daily_paid_payment,     type: Float

end