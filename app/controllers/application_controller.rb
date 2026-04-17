class ApplicationController < ActionController::Base
  include TenantScoped
  include Pundit::Authorization

  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :authenticate_user!

  after_action :verify_authorized,    unless: -> { devise_controller? || action_name == "index" }
  after_action :verify_policy_scoped, unless: -> { devise_controller? || action_name != "index" }

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "No tenés permiso para realizar esta acción."
    redirect_back fallback_location: root_path
  end

  def current_user_roles
    return [] unless current_user && current_school
    @current_user_roles ||= UserRoleSchool.where(user: current_user, school: current_school)
                                          .active_on
                                          .pluck(:role)
  end
  helper_method :current_user_roles

  def current_user_has_role?(*roles)
    (current_user_roles & roles.map(&:to_s)).any?
  end
  helper_method :current_user_has_role?

  def after_sign_in_path_for(_resource)
    stored_location_for(_resource) || root_path
  end
end
