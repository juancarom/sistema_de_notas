class Students::BaseController < ApplicationController
  skip_after_action :verify_authorized,    raise: false
  skip_after_action :verify_policy_scoped, raise: false
  before_action :require_student_or_staff!

  private

  def require_student_or_staff!
    unless current_user_has_role?(:super_admin, :admin, :principal, :student_office, :proctor, :teacher, :student)
      flash[:alert] = "Acceso no autorizado."
      redirect_to root_path
    end
  end
end
