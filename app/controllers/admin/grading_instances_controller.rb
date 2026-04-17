class Admin::GradingInstancesController < Admin::BaseController
  before_action :set_grading_instance, only: [:show, :edit, :update, :destroy, :toggle_enabled]

  def index
    @study_plan = StudyPlan.find_by(id: params[:study_plan_id])
    scope = policy_scope(GradingInstance)
    scope = scope.where(study_plan: @study_plan) if @study_plan
    @grading_instances = scope.order(:academic_year, :position)
    @study_plans = StudyPlan.order(:name)
  end

  def show
    authorize @grading_instance
    skip_authorization # show uses authorize above, not policy_scope
  end

  def new
    authorize GradingInstance
    @grading_instance = GradingInstance.new
    @study_plans = StudyPlan.order(:name)
    @study_plan = StudyPlan.find_by(id: params[:study_plan_id])
    @grading_instance.study_plan = @study_plan
  end

  def create
    authorize GradingInstance
    @grading_instance = GradingInstance.new(grading_instance_params)
    if @grading_instance.save
      redirect_to admin_grading_instances_path(study_plan_id: @grading_instance.study_plan_id),
                  notice: "Instancia de notas creada."
    else
      @study_plans = StudyPlan.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @grading_instance
    @study_plans = StudyPlan.order(:name)
  end

  def update
    authorize @grading_instance
    if @grading_instance.update(grading_instance_params)
      redirect_to admin_grading_instances_path(study_plan_id: @grading_instance.study_plan_id),
                  notice: "Instancia actualizada."
    else
      @study_plans = StudyPlan.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @grading_instance
    @grading_instance.destroy
    redirect_to admin_grading_instances_path, notice: "Instancia eliminada."
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to admin_grading_instances_path, alert: "No se puede eliminar: tiene notas cargadas."
  end

  def toggle_enabled
    authorize @grading_instance
    @grading_instance.update!(enabled: !@grading_instance.enabled)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "grading_instance_#{@grading_instance.id}",
          partial: "admin/grading_instances/grading_instance",
          locals: { grading_instance: @grading_instance }
        )
      end
      format.html { redirect_back fallback_location: admin_grading_instances_path }
    end
  end

  private

  def set_grading_instance
    @grading_instance = GradingInstance.joins(:study_plan)
                                       .where(study_plans: { school: current_school })
                                       .find(params[:id])
  end

  def grading_instance_params
    params.require(:grading_instance).permit(
      :study_plan_id, :name, :position, :grade_type, :is_final,
      :academic_year, :entry_open_at, :entry_close_at, :visible_from, :visible_until
    )
  end
end
