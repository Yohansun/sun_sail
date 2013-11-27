# == Schema Information
#
# Table name: taobao_skus
#
#  id                :integer(4)      not null, primary key
#  sku_id            :integer(8)
#  taobao_product_id :integer(8)
#  num_iid           :integer(8)
#  properties        :string(255)
#  properties_name   :string(255)
#  quantity          :integer(4)
#  account_id        :integer(4)
#

class TaobaoSku < ActiveRecord::Base
  attr_protected []
  has_many :sku_bindings,:include => :sku, dependent: :destroy,:conditions => {:resource_type => "TaobaoSku"},:foreign_key => :resource_id
  has_many :skus,:include => :product, through: :sku_bindings
  belongs_to :taobao_product
  belongs_to :account

  def title
    "#{taobao_product.try(:name)}#{name}"
  end

  def name
    sku_name = ''
    if properties_name.present?
      properties = properties_name.split(';')
      properties.each do |property|
        sku_values = property.split(':')
        sku_key =  sku_values[2]
        sku_value =  sku_values[3]
        sku_name = sku_name + sku_key + ':' + sku_value + '  '
      end
    end
    sku_name
  end

  def value
    value = ''
    if properties_name.present?
      properties = properties_name.split(';')
      properties.each do |property|
        sku_values = property.split(':')
        sku_value =  sku_values[3]
        value = sku_value + ' '
      end
    end
    value
  end

  def number(local_sku_id)
    sku_bindings.where(sku_id: local_sku_id).first.number
  end
end
