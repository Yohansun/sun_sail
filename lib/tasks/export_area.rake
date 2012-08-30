# -*- encoding: utf-8 -*-

desc "导出地区"
task :export_area => :environment  do
	require 'csv' 
   
    areas = Area.all

	CSV.open("area_export_20120829.csv", 'wb') do |csv| 
	    csv << ['省份','市','区','经销商']  
		    puts "starting................"
		    
        areas.each do |area|
        	
            province = nil
            city = nil
            district = nil
            seller_name = nil
            
            if area.parent_id == nil               
            elsif area.parent_id == 1
            	province = area.name
            else	                		
        	    city = Area.where(id: area.parent_id).first
                unless city.parent_id.blank?
                    province = Area.where(id: city.parent_id).first
                    unless province.parent_id.blank?
	                    province = Area.where(id: city.parent_id).first.name	
	                    city = city.name
	                    district = area.name
	                else
	                    province = Area.where(id: area.parent_id).first.name
                        city = area.name    
	                end               	
                end    
            end    

            if area.seller_id   
                seller_name = Seller.where(id: area.seller_id).first.try(:name)
            end

            csv << [province, city, district, seller_name] 
            puts "Fetching.......%s" % area.name  

        end

        puts "End of Fetch" 

    end    
end
