# -*- encoding:utf-8 -*-

class TaobaoOrder < Order

  field :oid, type: String
  field :status, type: String
  # field :refund_status, type: String

  field :outer_id, type: String
  field :outer_iid, type: String
  field :num_iid, type: String
  # field :local_product_id, type: Integer

  field :sku_id, type: String

  field :outer_sku_id, type: String
  field :sku_properties_name, type: String
  field :title, type: String
  field :price, type: Float, default: 0.0
  field :num, type: Integer
  field :total_fee, type: Float, default: 0.0
  field :payment, type: Float, default: 0.0
  field :discount_fee, type: Float, default: 0.0
  field :adjust_fee, type: Float

  field :item_meal_id, type: String
  field :item_meal_name, type: String
  field :modified, type: DateTime
  field :refund_id, type: String
  field :is_oversold, type: Boolean
  field :is_service_order, type: Boolean
  field :end_time, type: DateTime
  field :pic_path, type: String
  field :seller_nick, type: String
  field :buyer_nick, type: String
  field :snapshot_url, type: String
  field :snapshot, type: String
  field :timeout_action_time, type: DateTime
  field :buyer_rate, type: Boolean
  field :seller_rate, type: Boolean
  field :seller_type, type: String
  field :cid, type: Integer

  embedded_in :taobao_trades
  embedded_in :custom_trades
  embedded_in :trades

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
    taobao_sku.sku_bindings rescue []
  end

  def local_skus
    sku = Sku.find_by_id(local_sku_id)
    sku == nil ? [] : [sku]
  end

  def skus
    (taobao_sku && taobao_sku.skus) || local_skus || []
  end

  def products
    skus.map(&:product)
  end

  def categories
    products.map(&:category)
  end

  def package_info
    info = []
    if sku_bindings.present?
      sku_bindings.each do |binding|
        sku = binding.sku
        next unless sku
        product = sku.product
        next unless product
        stock_product_ids = StockProduct.where(product_id: product.id, sku_id: sku.id).map(&:id)
        info << {
          sku_id: binding.sku_id,
          outer_id: product.outer_id,
          stock_product_ids: stock_product_ids,
          number: binding.number,
          title: sku.title
        }
      end
    elsif local_skus.present?
      local_skus.each do |sku|
        product = sku.product
        next unless product
        stock_product_ids = StockProduct.where(product_id: product.id, sku_id: sku.id).map(&:id)
        info << {
          sku_id: sku.id,
          outer_id: product.outer_id,
          stock_product_ids: stock_product_ids,
          number: 1,
          title: sku.title
        }
      end
    end
    info
  end

  def package_products
    info = []
    if sku_bindings.present?
      sku_bindings.each do |binding|
        product = binding.sku.try(:product)
        number = binding.number
        info << Array.new(number,product)
      end
    elsif local_skus.present?
      local_skus.each do |sku|
        product = sku.product
        info << Array.new(1,product)
      end
    end
    info = info.flatten
  end

  def child_outer_id
    info = []
    if sku_bindings.present?
      sku_bindings.each do |binding|
        product = binding.sku.try(:product)
        number = binding.number
        info << [product, number]
      end
    elsif local_skus.present?
      local_skus.each do |sku|
        product = sku.product
        info << [product, 1]
      end
    end
    info
  end

  def sku_products
    products = []
    if self.sku_bindings.present?
      self.sku_bindings.each do |binding|
        sku_id = binding.sku_id
        sku = Sku.find_by_id(sku_id)
        product = sku.try(:product)
        products << {sku_id: sku_id, number: binding.number, product: product} if product.present?
      end
    elsif self.local_skus.present?
      self.local_skus.each do |sku|
        sku_id = sku.id
        sku = Sku.find_by_id(sku_id)
        product = sku.try(:product)
        products << {sku_id: sku_id, number: 1, product: product} if product.present?
      end
    end

    products
  end

  def avalibale_sku_names
    sku_names = []
    if taobao_skus.present?
      taobao_skus.map(&:name).each do |name|
        sku_names << name.split(':').last
      end
    elsif local_skus.present?
      local_skus.map(&:name).each do |name|
        sku_names << name.split(':').last
      end
    end
    sku_names.join(',')
  end


  def color_map(color_num)
    result = []
    # if products.count > 0
    #   result = package_color_map(color_num)
    # else
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
    # end

    # result
  end

  # def package_color_map(color_num)
  #   tmp_hash = package_info
  #   color_num.each do |nums|
  #     i = 0
  #     next if nums.blank?
  #     package_info.each_with_index do |package, index|
  #       colors = tmp_hash[index][:colors] || {}
  #       package[:number].times do
  #         color = nums[i]
  #         i += 1
  #         next if color.blank?
  #         if colors.has_key? color
  #           colors["#{color}"][0] += 1
  #         else
  #           colors["#{color}"] = [1, Color.find_by_num(color).try(:name)]
  #         end
  #         tmp_hash[index][:colors]  = colors
  #       end
  #     end
  #   end
  #   tmp_hash
  # end

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

  def order_price
    order_payment / num
  end

  def order_payment
    if taobao_trades
      if taobao_trades.orders.count == 1
        fee = payment - taobao_trades.post_fee
      else
        fee = payment
      end
    elsif custom_trades
      fee = payment
    elsif trades
      fee = payment
    end
    fee
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
