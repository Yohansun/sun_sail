# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: products
#
#  id            :integer(4)      not null, primary key
#  name          :string(100)     default(""), not null
#  outer_id      :string(20)      default(""), not null
#  product_id    :string(20)      default(""), not null
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
#  pic_url       :string(255)
#  detail_url    :string(255)
#  cid           :string(255)
#  num_iid       :integer(8)
#

class Product < ActiveRecord::Base

  acts_as_nested_set
  belongs_to :category
  belongs_to :quantity
  has_many :feature_product_relationships
  has_many :features, :through => :feature_product_relationships
  has_many :colors_products
  has_many :colors, through: :colors_products
  has_many :packages
  has_many :stock_products
  has_many :skus

  attr_accessible :good_type, :name, :outer_id, :product_id, :storage_num, :price, :quantity_id, :color_ids, :pic_url, :category_id, :features, :product_image, :feature_ids, :cat_name, :detail_url, :num_iid, :cid


  validates_presence_of  :name, :price, message: "信息不能为空"
  validates_uniqueness_of :outer_id, :allow_blank => true, message: "信息已存在"
 
  validates_numericality_of :price, message: "所填项必须为数字"
  validates_length_of :name, maximum: 100, message: "内容过长"
  validates_length_of :outer_id, :product_id, :price, maximum: 20, message: "内容过长"

  def present_features
    features.map(&:name).join(',')
  end

  def create_packages(child_iid)
    package_map = child_iid.gsub(' ', '').split(',[').each {|i| i.gsub!(/[\[|\]]/, '')}

    package_map.each do |p|
      p = p.split(',')

      next if p[0].blank? || p[0] == outer_id
      next unless Product.exists?(outer_id: p[0])

      packages.create(
        number: p[1],
        outer_id: p[0]
      )
    end
  end

  def package_info
    info = []
    packages.each do |item|
      product = Product.find_by_outer_id(item.outer_id)
      info << {
        outer_id: item.outer_id,
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
