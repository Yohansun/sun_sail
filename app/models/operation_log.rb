class OperationLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :operation,      type: String
  field :operated_at,    type: DateTime
  field :operator,       type: String
  field :operator_id,    type: Integer

  embedded_in :trades

  def account_id
    trades.account_id
  end
end
