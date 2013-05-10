class RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :authenticate_scope!
  prepend_view_path "devise"
end
