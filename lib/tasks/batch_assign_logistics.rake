# -*- encoding : utf-8 -*-
task :batch_assign_logistics => :environment do 
	old_logistic_id = ENV['old_logistic_id']
  new_logistic_id = ENV['new_logistic_id']
  logistics = LogisticArea.where(Logistic_id: old_logistic_id)
	logistics.each do |old_logistic| 
    unless LogisticArea.where(Logistic_id: new_logistic_id, area_id: old_logistic.area_id).first.present?
      YTO_logistic = old_logistic.clone
      YTO_logistic.logistic_id = new_logistic_id
      YTO_logistic.save!
      p "add logistic_id #{YTO_logistic.logistic_id} for area_id #{old_logistic.area_id}"
    end
  end  
end