# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: products
#
#  id            :integer(4)      not null, primary key
#  name          :string(100)     default(""), not null
#  iid           :string(20)      default(""), not null
#  taobao_id     :string(20)      default(""), not null
#  storage_num   :string(20)      default(""), not null
#  price         :decimal(8, 2)   default(0.0), not null
#  quantity_id   :integer(4)
#  category_id   :integer(4)
#  features      :string(255)
#  product_image :string(255)
#  parent_id     :integer(4)
#  lft           :integer(4)      default(0)
#  rgt           :integer(4)      default(0)
#  good_type     :integer(4)
#  updated_at    :datetime
#  created_at    :datetime
#  cat_name      :string(255)
#  props_str     :text
#  binds_str     :text
#  pic_url       :string(255)
#  account_id    :integer(4)
#

class Product < ActiveRecord::Base

  # ========================
  #  Attributes desc
  #    - iid: 淘宝编码，从淘宝获取outer_iid
  #    - taobao_id: 淘宝商品produc_id， 可作为淘宝商品的唯一标示，暂未使用''
  #    - cat_name: 商品类目名称
  #    - props_str: 产品的关键属性字符串列表.比如:品牌:诺基亚;型号:N73
  #    - binds_str: 产品的非关键属性字符串列表
  # ========================

  acts_as_nested_set
  belongs_to :category
  belongs_to :quantity
  has_many :feature_product_relationships
  has_many :features, :through => :feature_product_relationships
  has_many :colors_products
  has_many :colors, through: :colors_products
  has_many :packages
  has_many :stock_products

  attr_accessible :good_type, :name, :iid, :taobao_id, :storage_num, :price, :quantity_id, :color_ids, :pic_url,
                  :category_id, :features, :product_image, :feature_ids, :cat_name, :props_str, :binds_str

  validates_presence_of :iid, :name, :price, message: "信息不能为空"
  validates_uniqueness_of :iid, :allow_blank => true, message: "信息已存在"
 
  validates_numericality_of :price, message: "所填项必须为数字"
  validates_length_of :name, maximum: 100, message: "内容过长"
  validates_length_of :iid, :taobao_id, :price, maximum: 20, message: "内容过长"

  def present_features
    features.map(&:name).join(',')
  end

  def create_packages(child_iid)
    package_map = child_iid.gsub(' ', '').split(',[').each {|i| i.gsub!(/[\[|\]]/, '')}

    package_map.each do |p|
      p = p.split(',')

      next if p[0].blank? || p[0] == iid
      next unless Product.exists?(iid: p[0])

      packages.create(
        number: p[1],
        iid: p[0]
      )
    end
  end

  def package_info
    info = []
    packages.each do |item|
      product = Product.find_by_iid(item.iid)
      info << {
        iid: item.iid,
        number: item.number,
        storage_num: product.try(:storage_num),
        title: product.try(:name)
      }
    end

    info
  end

  def color_map(color_num)
    result = []
    if packages.count > 0
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
        iid: iid,
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
