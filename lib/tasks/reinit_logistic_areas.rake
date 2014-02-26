# -*- encoding : utf-8 -*-
require "csv"
desc "重置物流商地域20140225"
task :reinit_logistic_areas => :environment do
  p "---------------------------truncate logistic_areas----------------------------"
  ActiveRecord::Base.connection.execute('truncate logistic_areas;')
  p "删除所有物流商地域绑定数据"
  p "------------------------------------------------------------------------------"
  open("#{Rails.root}/lib/tasks/dulux/reinit_logistic_areas.csv").readlines.each do |line|
    row = line.split(",")
    state_name = row[0].try(:strip)
    city_name = row[1].try(:strip)
    district_name = row[2].try(:strip)
    logistic_company = [] << row[3].try(:strip)
    logistic_company = logistic_company << row[4].try(:strip)
    logistic_company = logistic_company << row[5].try(:strip)

    state = city = area = nil
    state = Area.find_by_name state_name
    city = state.children.where(name: city_name).first if state
    area = city.children.where(name: district_name).first if city
    address = area || city || state

    if address.present?
      if logistic_company.present?
        logistic_company.each do |name|
          logistic = Logistic.find_by_name(name)
          next unless logistic
          logistic.areas = logistic.areas << address
          p name + " 绑定 " + address.name
        end
      end
    else
      p "地域 #{address} 不存在"
    end

  end

end