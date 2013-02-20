# -*- encoding : utf-8 -*-
class WangwangReplyState
  include Mongoid::Document
  field :account_id, type: Integer
  field :user_id,    type: String
  field :reply_num,  type: Integer
  field :reply_date, type: Integer
end