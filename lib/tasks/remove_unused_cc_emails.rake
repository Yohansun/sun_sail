# -*- encoding : utf-8 -*-
#删除cc_emails中的YaoYanMing@nipponpaint.com.cn
task :remove_yaoyanming_cc_emails => :environment do
  yaoyanming = 'YaoYanMing@nipponpaint.com.cn'
  Seller.where("cc_emails is not null").find_each do |s|
    cc_array = s.cc_emails.split(',')
    if cc_array.include? yaoyanming
      p s.cc_emails
      cc_array = cc_array - [yaoyanming]
      new_cc_emails = cc_array.join(',')
      s.cc_emails = new_cc_emails.strip
      s.save
      p "------------------------------------------------------------------------"
      p s.cc_emails
    end
  end
end
#删除cc_emails中的JaneZhao@nipponpaint.com.cn
task :remove_janezhao_cc_emails => :environment do
  janezhao = 'JaneZhao@nipponpaint.com.cn'
  Seller.where("cc_emails is not null").find_each do |s|
    cc_array = s.cc_emails.split(',')
    if cc_array.include? janezhao
      p s.cc_emails
      cc_array = cc_array - [janezhao]
      new_cc_emails = cc_array.join(',')
      s.cc_emails = new_cc_emails.strip
      s.save
      p "------------------------------------------------------------------------"
      p s.cc_emails
    end
  end
end
#删除cc_emails中的menlulu@nipponpaint.com.cn
task :remove_menlulu_cc_emails => :environment do
  menlulu = 'menlulu@nipponpaint.com.cn'
  Seller.where("cc_emails is not null").find_each do |s|
    cc_array = s.cc_emails.split(',')
    if cc_array.include? menlulu
      p s.cc_emails
      cc_array = cc_array - [menlulu]
      new_cc_emails = cc_array.join(',')
      s.cc_emails = new_cc_emails.strip
      s.save
      p "------------------------------------------------------------------------"
      p s.cc_emails
    end
  end
end

#删除cc_emails中的chendonglin@nipponpaint.com.cn
task :remove_chendonglin_cc_emails => :environment do
  chendonglin = 'chendonglin@nipponpaint.com.cn'
  Seller.where("cc_emails is not null").find_each do |s|
    cc_array = s.cc_emails.split(',')
    if cc_array.include? chendonglin
      p s.cc_emails
      cc_array = cc_array - [chendonglin]
      new_cc_emails = cc_array.join(',')
      s.cc_emails = new_cc_emails.strip
      s.save
      p "------------------------------------------------------------------------"
      p s.cc_emails
    end
  end
end