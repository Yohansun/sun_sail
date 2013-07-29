class JingdongOrder < Order

  field :sku_id,                      type: String
  field :outer_sku_id,                type: String
  field :sku_name,     as: :title,    type: String # 商品的名称+SKU规格

  field :jd_price,     as: :price,    type: Float
  field :item_total,   as: :num,      type: Integer
  field :ware_id,      as: :num_iid,  type: String

  #京东子订单特有字段
  field :gift_point,                  type: String

  embedded_in :jingdong_trades

  def account_id
    jingdong_trades.account_id
  end

  def product
    super(outer_sku_id)
  end

  def sku_properties
    #DO SOMETHING WITH SKU_NAME
  end

  def bill_info
    tmp = {}
    color_num.each do |nums|
      next if nums.blank?

      num = nums[0]
      next if num.blank?

      if tmp.has_key? num
        tmp["#{num}"][0] += 1
      else
        tmp["#{num}"] = [1, Color.find_by_num(num).try(:name)]
      end
    end

    [{
      outer_id: '',
      number: 1,
      storage_num: '',
      title: sku_name,
      colors: tmp
    }]
  end
end
