# encoding : utf-8 -*-
require 'cgi'
class LogisticRatePuller
  class << self
    # Every 5 seconds
    def create
    	response = Sms.receive
    	if response.respond_to?(:include?) && response.include?('Msg')
    		response =  CGI::parse(response)
    		mobile = response.fetch("Mobile").first
        if LogisticRate.where(mobile: mobile).exists?
        	score = response.fetch("Msg").first.to_i
        	return unless [1,3,5].include? score
          if LogisticRate.where(mobile: mobile).where("score is null")
            record = LogisticRate.where(mobile: mobile).where("score is null").last
          else  
        	  record = LogisticRate.where(mobile: mobile).last
          end 
    			record.score = score if (!record.score || record.score > score )
    			record.save
    		end	
      end
    end
  end    
end    	