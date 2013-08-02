#encoding: utf-8
class TransactionHistory
  include Mongoid::Document
  include Mongoid::Timestamps
  include MagicEnum

  field :tid               , type: String
  field :num_iid           , type: String
  field :status            , type: String
  field :type              , type: String
  field :created           , type: DateTime
  field :payment           , type: Float
  field :receiver_name     , type: String
  field :receiver_state    , type: String
  field :receiver_city     , type: String
  field :receiver_district , type: String
  field :receiver_address  , type: String
  field :receiver_zip      , type: String
  field :receiver_mobile   , type: String
  field :receiver_phone    , type: String
  field :account_id        , type: Integer
  field :product_ids       , type: Array, default: []

  enum_attr :status, TaobaoTrade::STATUS,:not_valid => true

  embedded_in :customer,:inverse_of => :transaction_histories
  
  after_save { customer.touch }

  validates :tid, :presence => true,:uniqueness => true
  belongs_to :trade,:class_name => "Trade", :foreign_key => "tid",:primary_key => "tid"

end