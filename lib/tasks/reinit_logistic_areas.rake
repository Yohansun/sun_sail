# -*- encoding : utf-8 -*-
require "csv"
desc "重置物流商地域20140225"
task :reinit_logistic_areas => :environment do
  p "---------------------------truncate logistic_areas----------------------------"
  ActiveRecord::Base.connection.execute('truncate logistic_areas;')
  p "删除所有物流商地域绑定数据"
  p "------------------------------------------------------------------------------"

  account = Account.find(1)

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
          logistic = account.logistics.find_by_name(name)
          next unless logistic
          logistic.areas = logistic.areas << address
          p name + " 绑定 " + address.name
        end
      end
    else
      p "地域 #{address} 不存在"
    end

  end

  hd_logistic = account.logistics.find_by_name "虹迪"
  cd_seller = account.sellers.find_by_name "成都物流"
  bj_seller = account.sellers.find_by_name "北京物流"
  se_logistic = account.logistics.find_by_name "速尔快递"
  nd_logistic = account.logistics.find_by_name "能达速递"
  ys_logistic = account.logistics.find_by_name "优速快递"

  #虹迪：管辖地区设置成和经销商“成都物流”的绑定地域完全一致
  cd_seller.areas.each do |area|
    hd_logistic.area_ids |= [area.id]
    hd_logistic.save!
    p hd_logistic.name + " 绑定 " + area.name
  end

  #速尔快递、能达速递、优速快递：管辖地区设置成和经销商“北京物流”的绑定地域 完全一致。
  bj_seller.areas.each do |area|
    se_logistic.area_ids |= [area.id]
    se_logistic.save!
    p se_logistic.name + " 绑定 " + area.name
    nd_logistic.area_ids |= [area.id]
    nd_logistic.save!
    p nd_logistic.name + " 绑定 " + area.name
    ys_logistic.area_ids |= [area.id]
    ys_logistic.save!
    p ys_logistic.name + " 绑定 " + area.name
  end

end