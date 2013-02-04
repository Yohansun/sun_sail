class SessionsController < Devise::SessionsController

  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    session[:account_id] = self.resource.accounts.first.try(:id)
    respond_with resource, :location => after_sign_in_path_for(resource)
  end

end
