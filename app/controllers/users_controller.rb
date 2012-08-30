class UsersController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

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

  def index
  end

  def show
  end  
  
  def create
  end

  def update      
  end

end
