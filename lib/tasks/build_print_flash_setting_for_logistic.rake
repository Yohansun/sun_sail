# -*- encoding:utf-8 -*-

desc "为没有物流单模板的物流商添加模板"
task :build_print_flash_setting_for_logistic => :environment do
  puts "start building"
  Logistic.includes(:print_flash_setting).where("print_flash_settings.id is null").find_each do |logistic|
    logistic.create_print_flash_setting
  end
  puts "end building"
end