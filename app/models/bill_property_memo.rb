# encoding: utf-8

class BillPropertyMemo < PropertyMemo

  field :used, type: Boolean, default: false

  belongs_to :stock_in_bill

  index stock_in_bill_id: 1

end