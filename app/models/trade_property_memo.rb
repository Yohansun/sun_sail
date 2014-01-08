# encoding: utf-8

class TradePropertyMemo < PropertyMemo

  field :oid,               type: String

  belongs_to  :trade

end