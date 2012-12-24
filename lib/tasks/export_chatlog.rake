# -*- encoding:utf-8 -*-
require 'csv'
task :export_chatlog => :environment do
  CSV.open("export_chatlog_20121228.csv", 'wb') do |csv| 
    p "STARTING~~~~~~~~~~~"
    csv << ['客服','客户','开始时间','结束时间','谈话内容']  
  	
    chatlogs = WangwangChatlog.where(date: 1353715200).where(:user_id.in => ["cntaobao立邦漆官方旗舰店:亮钻","cntaobao立邦漆官方旗舰店:皓白"])
    p chatlogs.count
    chatlogs.each do |log|
      if log.user_id == "cntaobao立邦漆官方旗舰店:亮钻"
        clerk = '吴航军'
      else  
        clerk = '高钰霖'
      end
      buyer = log.buyer_nick
      p clerk
      p buyer
      start_at = log.start_time.strftime("%Y-%m-%d %H:%M:%S")
      end_at = log.end_time.strftime("%Y-%m-%d %H:%M:%S")
      msgs = []
      log.wangwang_chatmsgs.each do |msg|
        msgs << msg.content
      end
      msgs = msgs.join("  ")
      csv << [clerk, buyer, start_at, end_at, msgs]
    end
    p "END"
  end
end    


