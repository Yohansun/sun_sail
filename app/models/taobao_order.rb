# -*- encoding:utf-8 -*-

class TaobaoOrder < Order
  field :oid, type: String
  field :status, type: String
  field :outer_id, type: String
  field :title, type: String
  field :price, type: Float
  field :num_iid, type: String
  field :item_meal_id, type: String
  field :item_meal_name, type: String
  field :sku_id, type: String
  field :num, type: Integer
  field :outer_sku_id, type: String
  field :total_fee, type: Float, default: 0.0
  field :payment, type: Float
  field :discount_fee, type: Float
  field :adjust_fee, type: Float
  field :modified, type: DateTime
  field :sku_properties_name, type: String
  field :refund_id, type: String
  field :is_oversold, type: Boolean
  field :is_service_order, type: Boolean
  field :end_time, type: DateTime
  field :pic_path, type: String
  field :seller_nick, type: String
  field :buyer_nick, type: String
  field :refund_status, type: String
  field :outer_iid, type: String
  field :snapshot_url, type: String
  field :snapshot, type: String
  field :timeout_action_time, type: DateTime
  field :buyer_rate, type: Boolean
  field :seller_rate, type: Boolean
  field :seller_type, type: String
  field :cid, type: Integer

  embedded_in :taobao_trades
  embedded_in :gift_trades

  def account_id
    taobao_trades.account_id
  end

  def item_outer_id
    outer_iid
  end

  def sku_properties
    sku_properties_name
  end

  def taobao_sku
    if sku_id.present?
      TaobaoSku.find_by_sku_id(sku_id)
    else
      TaobaoSku.find_by_num_iid(num_iid)
    end
  end

  def sku_bindings
    taobao_sku.sku_bindings
  end

  def package_info
    info = []
    sku_bindings.each do |binding|
      sku = binding.sku
      product = sku.product
      stock_product_ids = StockProduct.where(product_id: product.id, sku_id: sku.id).map(&:id)
      info << {
        sku_id: binding.sku_id,
        outer_id: product.outer_id,
        stock_product_ids: stock_product_ids,
        number: binding.number,
        title: sku.title
      }
    end
    info
  end

  def package_products
    info = []
    sku_bindings.each do |binding|
      product = binding.sku.try(:product)
      number = binding.number
      info << Array.new(number,product)
    end
    info = info.flatten
  end

  def child_outer_id
    info = []
    sku_bindings.each do |binding|
      product = binding.sku.try(:product)
      number = binding.number
      info << [product, number]
    end
    info
  end

  def avalibale_sku_names
    sku_names = []
    taobao_skus.map(&:name).each do |name|
      sku_names << name.split(':').last
    end
    sku_names.join(',')
  end


  def color_map(color_num)
    result = []
    if products.count > 0
      result = package_color_map(color_num)
    else
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

      result = [{
        outer_id: outer_id,
        number: 1,
        storage_num: storage_num,
        title: name,
        colors: tmp
      }]
    end

    result
  end

  def package_color_map(color_num)
    tmp_hash = package_info
    color_num.each do |nums|
      i = 0
      next if nums.blank?
      package_info.each_with_index do |package, index|
        colors = tmp_hash[index][:colors] || {}
        package[:number].times do
          color = nums[i]
          i += 1
          next if color.blank?
          if colors.has_key? color
            colors["#{color}"][0] += 1
          else
            colors["#{color}"] = [1, Color.find_by_num(color).try(:name)]
          end
          tmp_hash[index][:colors]  = colors
        end
      end
    end
    tmp_hash
  end

  # 匹配套装内单品调色信息
  #
  # def map_products_by_colors
  #   tmp_p = product
  #   return {} unless tmp_p
  #   tmp_p.map_packages_by_colors color_num
  # end

  def bill_info
    # if product
    #   product.color_map(color_num)
    # else
    #   tmp = {}
    #   color_num.each do |nums|
    #     next if nums.blank?

    #     num = nums[0]
    #     next if num.blank?

    #     if tmp.has_key? num
    #       tmp["#{num}"][0] += 1
    #     else
    #       tmp["#{num}"] = [1, Color.find_by_num(num).try(:name)]
    #     end
    #   end

    #   [{
    #     outer_id: '',
    #     number: 1,
    #     storage_num: '',
    #     title: title,
    #     colors: []
    #   }]
    # end

    [{
        outer_id: '',
        number: 1,
        storage_num: '',
        title: title,
        colors: []
      }]
  end

  def refund_status_text
    case self.refund_status
      when "WAIT_SELLER_AGREE" then "买家已经申请退款，等待卖家同意"
      when "SELLER_REFUSE_BUYER" then "卖家拒绝退款"
      when "WAIT_BUYER_RETURN_GOODS" then "卖家已经同意退款，等待买家退货"
      when "WAIT_SELLER_CONFIRM_GOODS" then "买家已经退货，等待卖家确认收货"
      when "CLOSED" then "退款关闭"
      when "SUCCESS" then "退款成功"
    end
  end

  def price
    origin_price =  attributes['price']
    (origin_price - promotion_discount_fee/num).to_f.round(2)
  end

  def promotion_discount_fee
    if taobao_trades
      if taobao_trades.promotion_details.present?
        discount_fee = taobao_trades.promotion_details.where(oid: oid).sum(:discount_fee)
      end
    end
    discount_fee ||  0
  end
end
