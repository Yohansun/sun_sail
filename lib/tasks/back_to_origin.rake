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
  WangwangDataReprocess.new.perform
end