# -*- encoding : utf-8 -*-
require 'digest'
class GoController < ApplicationController
  def npsellers
    key = 'xB&wh9jbeQ'
    if current_user
    	area = current_user.seller.blank? ? "" : current_user.seller.first.name
      secret = Digest::MD5.hexdigest("#{key}-#{current_user.username}-#{current_user.email}-#{area}")
      domain = Rails.env.production? ? "npsellers.doorder.com" : "npsellers.dev"
      
      redirect_to "http://#{domain}/auth?username=#{current_user.username}&email=#{current_user.email}&area=#{area}&secret=#{secret}"
    end
  end
end