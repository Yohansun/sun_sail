#encoding: utf-8
namespace :magic_order do
  desc "更新数据库表的字符集"
  task :update_charset => :environment do
    results = conn.execute("show table status from #{configuration['database']}")
    results = results.to_a.reject {|u| u.include?('utf8_general_ci')}
    tbl_names = results.each do |r|
      sql = "ALTER TABLE #{r.first} CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
      conn.execute(sql)
      puts sql
    end
  end

  def configuration
    ActiveRecord::Base.configurations[Rails.env]
  end

  def conn
    ActiveRecord::Base.connection
  end
end