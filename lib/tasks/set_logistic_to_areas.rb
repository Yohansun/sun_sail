# -*- encoding:utf-8 -*-
desc "Task description"
task :set_logistic_to_areas => :environment do
  areas = {
    '安徽省': '中通'
    '北京': '中通'
    '江苏省': '圆通'
    '甘肃省': '中通'
    '江西省': '中通'
    '山东省': '中通'
    '上海': '圆通'
    '浙江省': '中通'
    '河北省': '中通'
    '河南省': '中通'
    '黑龙江省': '中通'
    '福建省': '中通'
    '广东省': '中通'
    '吉林省': '中通'
    '广西壮族自治区': '中通'
    '贵州省': '中通'
    '辽宁省': '中通'
    '内蒙古自治区': '中通'
    '宁夏回族自治区': '中通'
    '青海省''中通'
    '海南省''中通'
    '山西省''中通'
    '陕西省''中通'
    '湖北省''中通'
    '湖南省''中通'
    '天津''中通'
    '四川省''中通'
    '新疆维吾尔自治区''中通'
    '云南省''中通'
    '重庆''中通'
  }

  areas.each do |area_name, logistic_name|
    area = Area.find_by_name area_name
    logistic = Logistic.find_by_name logistic_name
    return if area.blank? || logistic.blank?
    area.descendants.update_all(logistic_id: logistic.id)
  end
end
