class Admin::SchoolSettingsController < Admin::BaseController
  def show
    @school = current_school
    authorize @school, :show?, policy_class: SchoolSettingsPolicy
  end

  def edit
    @school = current_school
    authorize @school, :edit?, policy_class: SchoolSettingsPolicy
  end

  def update
    @school = current_school
    authorize @school, :update?, policy_class: SchoolSettingsPolicy
    if @school.update(school_params)
      redirect_to admin_school_settings_path, notice: "Configuración actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def school_params
    params.require(:school).permit(
      :name, :min_grade, :max_grade, :passing_grade,
      :address, :city, :province, :postal_code,
      :phone, :contact_email, :website,
      :logo, :banner
    )
  end
end
