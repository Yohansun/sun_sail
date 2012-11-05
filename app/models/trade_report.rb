# -*- encoding : utf-8 -*-
class TradeReport 
	include ActionView::Helpers::NumberHelper
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user
  field :conditions, type: Hash  
  field :export_name, type: String 
  field :user_id, type: Integer 
  field :performed_at, type:DateTime
  field :request_at, type:DateTime

  def export_report
    TradeReporter.perform_async(self.id)  	
  end

  def username
  	user = User.find_by_id self.user_id
  	user.try(:name)
  end	 	

  def status	
  	if self.performed_at && File.exist?(self.url) && !File.zero?(self.url)
  		"可用"
  	else
  		"不可用"
  	end	
  end

  def url
  	"#{Rails.root}/data/#{self.id}.xls"
  end	

  def size
  	if self.performed_at && File.exist?(self.url) && !File.zero?(self.url)
  		number_to_human_size(File.size(self.url))
  	else
  		"未知"
  	end		
  end	

  def ext_name
  	if self.performed_at && File.exist?(self.url) && !File.zero?(self.url)
  		File.extname self.url
  	else
  		"未知"
  	end
  end	

  def performed_time
  	if self.performed_at && File.exist?(self.url) && !File.zero?(self.url)
  		self.performed_at.to_s(:db)
  	else
  		"还未生成"
  	end	
  end	

end
