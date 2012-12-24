#-*- encoding:utf-8 -*-

desc "Init YML configration files for Redis/MongoDB/TaoBao: "
task :init_yml_files => :environment do
   cp(Rails.root.join('config', 'magic_setting.yml.example'), File.join('config', 'magic_setting.yml'), :verbose => true)
   cp(Rails.root.join('config', 'mongoid.yml.example'), File.join('config', 'mongoid.yml'), :verbose => true)
   cp(Rails.root.join('config', 'redis.yml.example'), File.join('config', 'redis.yml'), :verbose => true)
   cp(Rails.root.join('config', 'taobao.yml.template'), File.join('config', 'taobao.yml'), :verbose => true)
end
