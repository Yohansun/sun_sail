# -*- encoding : utf-8 -*-
class RefLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :operation,      type: String
  field :operated_at,    type: DateTime
  field :operator,       type: String
  field :operator_id,    type: Integer
  field :log_memo,       type: String

  embedded_in :ref_batches

end