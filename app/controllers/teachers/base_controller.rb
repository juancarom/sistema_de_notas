class Teachers::BaseController < ApplicationController
  skip_after_action :verify_authorized,    raise: false
  skip_after_action :verify_policy_scoped, raise: false
  before_action :require_teacher!

  private

  def require_teacher!
    unless current_user_has_role?(:super_admin, :admin, :principal, :teacher)
      flash[:alert] = "Acceso exclusivo para docentes."
      redirect_to root_path
    end
  end
end
