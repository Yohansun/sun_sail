# -*- encoding : utf-8 -*-
class TaobaoProduct < ActiveRecord::Base
  belongs_to :account
  belongs_to :category
  has_many :taobao_products_products
  has_many :products, through: :taobao_products_products

  attr_accessible :name, :product_id, :outer_id, :price, :pic_url, :category_id, :cat_name, :detail_url, :num_iid, :cid, :account_id

  validates_uniqueness_of :outer_id, :allow_blank => true, message: "信息已存在"
  
  def package_info
    info = []
    products.each do |product|
      info << {
        outer_id: product.outer_id,
        number: product.number(id),
        storage_num: product.try(:storage_num),
        title: product.try(:name)
      }
    end
    info
  end

  def package_products
    info = []
    products.each do |product|
      info << Array.new(product.number(id),product)
    end  
    info = info.flatten
  end  

  def child_outer_id
    info = []
    products.each do |product|
      info << [product, product.number(id)]
    end
    info
  end

  def child_outer_id_at(index)
    products[index].try(:outer_id)
  end

  def child_number_at(index)
    products[index].try(:number, id)
  end

  def avalibale_sku_names
    sku_names = []
    skus.map(&:name).each do |name|
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
end
