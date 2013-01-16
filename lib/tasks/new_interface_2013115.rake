# -*- encoding : utf-8 -*-
desc "经销商北区组织架构调整"
task :new_interface2013115 => :environment do

  seller1 = Seller.where(parent_id: 1385, fullname: '冀北销售部', name: '冀北销售部', mobile: '13383166816', email: 'zhangdayuan@nipponpaint.com.cn,guochunjie@nipponpaint.com.cn' , cc_emails: 'zhangyuxue@nipponpaint.com.cn,huricha@nipponpaint.com.cn,ZhongJing@nipponpaint.com.cn, LuJingRNMD@nipponpaint.com.cn, ShenWeiYu@nipponpaint.com.cn, ZhangQin@nipponpaint.com.cn, WuHangJun@nipponpaint.com.cn, YanFei.Allen@nipponpaint.com.cn, ShaoLiXing@nipponpaint.com.cn, ZhaoMengMeng@nipponpaint.com.cn, CaoZhiXiong@nipponpaint.com.cn, GaoYuLin@nipponpaint.com.cn, YangYueYue@nipponpaint.com.cn, taohong@nipponpaint.com.cn,jixiao@nipponpaint.com.cn').first_or_create
  user1 = User.where(username: '冀北销售部', name: '冀北销售部', email: 'zhangdayuan@nipponpaint.com.cn').first_or_create
  user1.update_attributes!(password: 123456) 
  seller1.update_attributes!(user_id: user1.id)
  user1.add_role :interface

  seller2 = Seller.where(parent_id: 1385, fullname: '冀南销售部', name: '冀南销售部', mobile: '13933866465', email: 'DengSiSi@nipponpaint.com.cn' , cc_emails: 'zengsong@nipponpaint.com.cn,ZhongJing@nipponpaint.com.cn, LuJingRNMD@nipponpaint.com.cn, ShenWeiYu@nipponpaint.com.cn, ZhangQin@nipponpaint.com.cn, WuHangJun@nipponpaint.com.cn, YanFei.Allen@nipponpaint.com.cn, ShaoLiXing@nipponpaint.com.cn, ZhaoMengMeng@nipponpaint.com.cn, CaoZhiXiong@nipponpaint.com.cn, GaoYuLin@nipponpaint.com.cn, YangYueYue@nipponpaint.com.cn, taohong@nipponpaint.com.cn,jixiao@nipponpaint.com.cn').first_or_create
  user2 = User.where(username: '冀南销售部', name: '冀南销售部', email: 'DengSiSi@nipponpaint.com.cn').first_or_create
  user2.update_attributes!(password: 123456) 
  seller2.update_attributes!(user_id: user2.id)
  user2.add_role :interface

  seller3 = Seller.find_by_name "内蒙销售部"
  seller3.update_attributes!(mobile: '13722110756', email: 'SiQinGaoWa@nipponpaint.com.cn' , cc_emails:'WangQun@nipponpaint.com.cn,ZhongJing@nipponpaint.com.cn, LuJingRNMD@nipponpaint.com.cn, ShenWeiYu@nipponpaint.com.cn, ZhangQin@nipponpaint.com.cn, WuHangJun@nipponpaint.com.cn, YanFei.Allen@nipponpaint.com.cn, ShaoLiXing@nipponpaint.com.cn, ZhaoMengMeng@nipponpaint.com.cn, CaoZhiXiong@nipponpaint.com.cn, GaoYuLin@nipponpaint.com.cn, YangYueYue@nipponpaint.com.cn, taohong@nipponpaint.com.cn,jixiao@nipponpaint.com.cn ')

  seller4 = Seller.find_by_name "山西销售部"
  seller4.update_attributes!(mobile: '18635783273', email: 'ZhaoRuiZhao@nipponpaint.com.cn, LiXin.Wendy@nipponpaint.com.cn' , cc_emails: 'JiXuHong@nipponpaint.com.cn,ZhongJing@nipponpaint.com.cn, LuJingRNMD@nipponpaint.com.cn, ShenWeiYu@nipponpaint.com.cn, ZhangQin@nipponpaint.com.cn, WuHangJun@nipponpaint.com.cn, YanFei.Allen@nipponpaint.com.cn, ShaoLiXing@nipponpaint.com.cn, ZhaoMengMeng@nipponpaint.com.cn, CaoZhiXiong@nipponpaint.com.cn, GaoYuLin@nipponpaint.com.cn, YangYueYue@nipponpaint.com.cn, taohong@nipponpaint.com.cn,jixiao@nipponpaint.com.cn ')

  seller5 = Seller.find_by_name "北京销售部"
  seller5_cc_emails = seller5.cc_emails + ",wudi@nipponpaint.com.cn"
  seller5.update_attributes!(cc_emails: seller5_cc_emails)

  lines = open('lib/tasks/new_interface_2013115.csv').readlines.each_with_index do |line|
    row = line.split(",").map { |e| e.strip }
    seller = Seller.find_by_fullname(row[3])  || Seller.find_by_name(row[3])
    if seller 
      interface = Seller.find_by_fullname(row[9]) || Seller.find_by_name(row[9])
      if interface
        seller.update_attributes!(parent_id: interface.id, interface: interface.fullname)
      else
        p "missing interface #{row[9]}"
      end  
    else  
      p "missing seller #{row[3]}"
    end
  end  
  Seller.rebuild!
end