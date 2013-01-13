#encoding: utf-8

desc "重设admin账号密码"
task :reset_admin_password => :environment do
  User.find_by_name('admin').update_attribute(:password, '12345678') if Rails.env.development?
end