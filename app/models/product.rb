# -*- encoding : utf-8 -*-

class Product < ActiveRecord::Base
  acts_as_nested_set
  belongs_to :category
  belongs_to :grade
  belongs_to :quantity
  has_many :feature_product_relationships
  has_many :features, :through => :feature_product_relationships
  has_many :colors_products
  has_many :colors, through: :colors_products
  has_many :packages
  has_many :stock_products

  mount_uploader :product_image, ProductImageUploader

  attr_accessible :good_type, :name, :iid, :taobao_id, :storage_num, :price, :status, :grade_id, :quantity_id, :color_ids,
                  :category_id, :features, :technical_data, :description, :product_image, :feature_ids

  validates_presence_of :iid, :name, :storage_num, :price, message: "信息不能为空"
  validates_uniqueness_of :iid, :name, :iid, :taobao_id, :allow_blank => true, message: "信息已存在"
  validates_numericality_of :price, message: "所填项必须为数字"
  validates_length_of :name, maximum: 100, message: "内容过长"
  validates_length_of :iid, :taobao_id, :storage_num, :price, maximum: 20, message: "内容过长"
  validates_length_of :technical_data, :description, maximum: 200, message: "内容过长"
  validates_numericality_of :taobao_id, :allow_blank => true, message: "所填项必须为数字"
  validates_format_of :storage_num, with: /^[0-9A-Z-]+$/, message: "格式错误"

  def select_status
  	[['上架', "ON_SALE"], ['下架', "SOLD_OUT"]]
  end

  def present_status
    case status
    when "ON_SALE"
      '上架'
    when "SOLD_OUT"
      '下架'
    end
  end

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
      tmp_hash.each do |package|
        package[:number].times do
          next if nums[i].blank?

          tmp = package[:colors] || {}

          if tmp.has_key? nums[i]
            tmp["#{nums[i]}"][0] += 1
          else
            tmp["#{nums[i]}"] = [1, Color.find_by_num(nums[i]).try(:name)]
          end

          package[:colors] = tmp

          i += 1
        end
      end
    end

    tmp_hash
  end
end
