class UsersController < ApplicationController
  def autologin
    user = User.find_by_name params[:username]
    if user.magic_key == params[:key]
      sign_in :user, user
      redirect_to root_path
    end
  end
end
