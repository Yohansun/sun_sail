# -*- encoding:utf-8 -*-

desc "给某物流商绑定全部地域"
task :add_all_sub_areas_to_logsitic => :environment do

  second_areas = Area.where(area_type: 3).reject{|area| area.children.present?}
  third_areas = Area.where(area_type: 4)
  binding_areas = third_areas + second_areas
  logistic = Account.find(1).logistics.find_by_name("其他")
  logistic.areas.delete_all
  binding_areas.each do |area|
    logistic.areas << area
  end
end