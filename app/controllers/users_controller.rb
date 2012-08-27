class UsersController < ApplicationController
  def autologin
  	redirect_url = '/'
    user = User.find_by_name params[:username]
    if user && user.magic_key == params[:key]
      sign_in :user, user

      case params[:source]
      when 'fenxiao'
      	redirect_url = '/trades/taobao_fenxiao'
      when 'jingdong'
      	redirect_url = '/trades/jingdong'
      end
    end
    
    redirect_to redirect_url
  end
end
