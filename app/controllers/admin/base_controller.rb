class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :require_admin!

  private

  def require_admin!
    unless current_user_has_role?(:super_admin, :admin, :principal, :student_office)
      flash[:alert] = "No tenés permiso para acceder al panel de administración."
      redirect_to root_path
    end
  end
end
