# encoding: utf-8
desc "更新绑定物流商20140225"
task :update_logistics_area => :environment do
  hd_logistic = Logistic.find_by_name "虹迪"
  cd_seller = Seller.find_by_name "成都物流"
  bj_seller = Seller.find_by_name "北京物流"
  se_logistic = Logistic.find_by_name "速尔快递"
  nd_logistic = Logistic.find_by_name "能达速递"
  ys_logistic = Logistic.find_by_name "优速快递"

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