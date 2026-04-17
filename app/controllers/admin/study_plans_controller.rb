class Admin::StudyPlansController < Admin::BaseController
  before_action :set_study_plan, only: [:show, :edit, :update, :destroy]

  def index
    @study_plans = policy_scope(StudyPlan).order(:name)
  end

  def show
    authorize @study_plan
    @subjects_by_year = @study_plan.study_plan_subjects
                                   .includes(:subject)
                                   .order(:year_in_plan, "subjects.name")
                                   .group_by(&:year_in_plan)
    @courses = @study_plan.courses.order(:academic_year, :year_in_plan, :name)
    @grading_instances = @study_plan.grading_instances.order(:academic_year, :position)
  end

  def new
    authorize StudyPlan
    @study_plan = StudyPlan.new
  end

  def create
    authorize StudyPlan
    @study_plan = StudyPlan.new(study_plan_params)
    if @study_plan.save
      redirect_to admin_study_plan_path(@study_plan), notice: "Plan de estudio creado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @study_plan
  end

  def update
    authorize @study_plan
    if @study_plan.update(study_plan_params)
      redirect_to admin_study_plan_path(@study_plan), notice: "Plan de estudio actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @study_plan
    @study_plan.destroy
    redirect_to admin_study_plans_path, notice: "Plan de estudio eliminado."
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to admin_study_plan_path(@study_plan), alert: "No se puede eliminar: tiene datos asociados."
  end

  private

  def set_study_plan
    @study_plan = StudyPlan.find(params[:id])
  end

  def study_plan_params
    params.require(:study_plan).permit(:name, :level, :duration_years, :plan_type, :start_year, :active)
  end
end
