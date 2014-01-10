# encoding: utf-8

class BillPropertyMemo < PropertyMemo

  field :used, type: Boolean, default: false
  field :stock_in_bill_tid, type: String

  belongs_to :stock_in_bill, :primary_key => "tid", :foreign_key => "stock_in_bill_tid"

  index stock_in_bill_tid: 1

end