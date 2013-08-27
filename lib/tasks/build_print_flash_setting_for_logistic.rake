# -*- encoding:utf-8 -*-

desc "为没有物流单模板的物流商添加模板"
task :build_print_flash_setting_for_logistic => :environment do
  puts "start building"
  have_print_flash_setting_logistic_ids = PrintFlashSetting.all.map(&:logistic_id)
  Logistic.all.each do |logistic|
    if !have_print_flash_setting_logistic_ids.include?(logistic.id)
      logistic.build_print_flash_setting
      logistic.save
    end
  end
  puts "end building"
end