class Auth::SessionsController < Devise::SessionsController
  skip_before_action :verify_authorized,    raise: false
  skip_before_action :verify_policy_scoped, raise: false
  skip_after_action  :verify_authorized,    raise: false
  skip_after_action  :verify_policy_scoped, raise: false

  layout "auth"
end
