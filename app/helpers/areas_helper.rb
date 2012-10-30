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

  #地域三级联动
  def area_tree(current = nil, flag = 0)
    flag = flag
    if current
      is_right = 1 if current.right_sibling == nil
      children = current.children
      return unless children
    
      html = "'0,#{current.self_and_ancestors.map { |a| a.id }.join(",")}':{"
    else
      html = "'0':{"
      children = Area.roots
      flag = 1
    end
    
    html << children.map { |child| "#{child.id}:'#{child.name.split.join(',').to_s}'" }.join(",")
       
    if flag == 1
      html << "},\n"
    else
      html << "}\n"
    end
      
    children.each do |child|
      if !child.leaf?
        if is_right && child.right_sibling == nil
          html << area_tree(child)
        else
          html << area_tree(child,1) 
        end
      end
    end
    
    html
  end
end
