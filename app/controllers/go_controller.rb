# -*- encoding : utf-8 -*-
require 'digest'
class Admin::GoController < Admin::BaseController
  def magicnippon
    key = 'xB&wh9jbeQ'
    if current_user
    	area = current_user.sellers.blank? ? "" : current_user.sellers.first.name
      secret = Digest::MD5.hexdigest("#{key}-#{current_user.username}-#{current_user.email}-#{area}")
      domain = Rails.env.production? ? "magicnippon.doorder.com" : "magicnippon.dev"
      
      redirect_to "http://#{domain}/auth?username=#{current_user.username}&email=#{current_user.email}&area=#{area}&secret=#{secret}"
    end
  end
end