module TenantScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_current_school
    helper_method :current_school
  end

  private

  def set_current_school
    subdomain = request.subdomain.presence

    if subdomain.blank?
      render plain: "Institución no encontrada. Verificá la URL.", status: :not_found and return
    end

    @current_school = School.kept.find_by(subdomain: subdomain)

    if @current_school.nil?
      render plain: "Institución '#{subdomain}' no encontrada.", status: :not_found and return
    end

    ActsAsTenant.current_tenant = @current_school
    Current.school = @current_school
  end

  def current_school
    @current_school
  end
end
