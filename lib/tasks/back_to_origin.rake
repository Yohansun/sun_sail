# -*- encoding : utf-8 -*-

desc "返璞归真"
task :back_to_origin => :environment do
  p "delete_chatlog"
  WangwangChatlog.delete_all
  p "delete_relpy_state"
  WangwangReplyState.delete_all
  p "delete_chatpeer"
  WangwangChatpeer.delete_all
  p "delete_member_contrast"
  WangwangMemberContrast.delete_all
  p "start_from_beginning"
  dates = ["2012-11-23","2012-11-24","2012-12-04","2012-12-05"]
  dates.each do |date|
    p date
    WangwangDataReprocess.new.perform(date.to_date, date.to_date)
  end
end