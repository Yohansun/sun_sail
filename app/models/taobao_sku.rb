class TaobaoSku < ActiveRecord::Base
  attr_accessible :sku_id, :num_iid, :properties, :properties_name, :quantity, :taobao_product_id
  has_many :sku_bindings
  has_many :skus, through: :sku_bindings
  belongs_to :taobao_product

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