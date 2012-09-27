module AreasHelper
	#地区树形结构
	def area
    areas = Area.where(parent_id: 1)
    @areas = []
    areas.each do |a|
      @areas << {id: a.id,pId: a.parent_id,name: a.name, open: false, nocheck: true} 
      tow = Area.where(parent_id: a.id)
      tow.each do |areas_t|
        r = Area.where(parent_id: areas_t.id)
        if r.present?
          @areas << {id: areas_t.id,pId: areas_t.parent_id,name: areas_t.name, open: false, nocheck: true}
          r.each do |areas_r|
            @areas << {id: areas_r.id,pId: areas_r.parent_id,name: areas_r.name}
          end
        else
          @areas << {id: areas_t.id,pId: areas_t.parent_id,name: areas_t.name}
        end
      end
    end
    @areas.to_json
	end
end
