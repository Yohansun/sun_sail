class UnusualState
  include Mongoid::Document
  include Mongoid::Timestamps

  field :reason,       type: String

  field :created_at,   type: DateTime
  field :reporter,     type: String
  field :repair_man,   type: String
  field :repaired_at,  type: DateTime

  embedded_in :trades
end