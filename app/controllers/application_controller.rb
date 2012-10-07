class ApplicationController < ActionController::Base
  protect_from_forgery

  def admin_only!
    unless user_signed_in? && current_user.has_role?(:admin)
      redirect_to root_path
      return false
    end
  end
end