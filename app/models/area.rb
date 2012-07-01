class Area < ActiveRecord::Base
  acts_as_nested_set
  attr_accessible :parent_id, :name, :is_1568, :area_type, :zip

  def self.sync_from_taobao
    Area.skip_callback :save
    response = TaobaoFu.get(method: "taobao.areas.get",
      fields: 'id, type, name, parent_id, zip')

    areas = response['areas_get_response']['areas']['area']
    areas.each do |taobao_area|
      taobao_area['parent_id'] = nil if taobao_area['parent_id'] == 0
      area = Area.new(name: taobao_area['name'],
        area_type: taobao_area['type'], parent_id: taobao_area['parent_id'],
        zip: taobao_area['zip'])
      area.id = taobao_area['id']
      area.save
    end
    Area.rebuild!
  end
end