# encoding: utf-8

class TradePropertyMemo < PropertyMemo

  field :stock_in_bill_tid

  belongs_to :trade
  belongs_to :order

  index trade_id: 1
  index order_id: 1
end