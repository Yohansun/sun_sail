class JingdongOrder < Order

	field :sku_id, type: String
	field :outer_sku_id, type: String
	field :sku_name, type: String
	field :jd_price, type: Float
	field :gift_point, type: String
	field :ware_id, type: String
	field :item_total, type: Integer

    embedded_in :jingdong_trades    
end