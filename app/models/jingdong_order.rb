class JingdongOrder < Order

  field :sku_id, type: String
  field :outer_sku_id, type: String
  field :sku_name, type: String
  field :jd_price, type: Float
  field :gift_point, type: String
  field :ware_id, type: String
  field :item_total, type: Integer

  embedded_in :jingdong_trades

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
      iid: '',
      number: 1,
      storage_num: '',
      title: sku_name,
      colors: tmp
    }]
  end
end
