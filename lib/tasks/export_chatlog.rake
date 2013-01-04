# -*- encoding:utf-8 -*-
require 'csv'
task :export_chatlog => :environment do
  CSV.open("export_chatlog_20121231.csv", 'wb') do |csv|
    p "STARTING~~~~~~~~~~~"
    csv << ['客服','客户','开始时间','结束时间','谈话内容']

    names = ["操志雄","晏飞","杨月月"]
    ids = []
    names.each do |name|
      ids << "cntaobao" + WangwangMember.where(name: name).first.user_id
      p ids
    end
  	
    chatlogs = WangwangChatlog.where(date: 1353715200).where(:user_id.in => ids)
    p chatlogs.count
    chatlogs.each do |log|
      clerk = WangwangMember.where(user_id: log.user_id.delete("cntaobao")).first.name
      buyer = log.buyer_nick
      p clerk
      p buyer
      start_at = log.start_time.strftime("%Y-%m-%d %H:%M:%S")
      end_at = log.end_time.strftime("%Y-%m-%d %H:%M:%S")
      msgs = []
      log.wangwang_chatmsgs.each do |msg|
        if msg.direction == "1"
          msgs << "用户：" +  msg.content.to_s
        else
          msgs << "客服：" + msg.content.to_s
        end
      end
      msgs = msgs.join("  ")
      csv << [clerk, buyer, start_at, end_at, msgs]
    end
    p "END"
  end
end