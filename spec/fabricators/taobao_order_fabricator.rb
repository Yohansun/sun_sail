# -*- encoding : utf-8 -*-

Fabricator(:taobao_order) do
  color_num      []
  color_hexcode  []
  color_name     []
  barcode        []
  _type          "TaobaoOrder"
  status         "WAIT_SELLER_SEND_GOODS"
  refund_status  "NO_REFUND"
  seller_type    "B"
  sku_id         ""
  outer_iid      "K-3831T-0"
  pic_path       "spec/fixtures/test.jpg"
  price          { sequence(:price)        {|i| 120.0 + i } }
  total_fee      { sequence(:total_fee)    {|i| 100.0 + i } }
  payment        { sequence(:payment)      {|i| 100.0 + i } }
  discount_fee   { sequence(:discount_fee) {|i| 0.0 + i } }
  oid            { sequence(:oid)          {|i| "000022222222222" + i.to_s } }
  num_iid        { sequence(:num_iid)      {|i| "863731213" + i.to_s } }
  num            { sequence(:num)          {|i| i } }
  title          { sequence(:title)        {|i| "测试商品 #{i}盒" } }
  cid            { sequence(:cid)          {|i| 50026809 + i } }
end