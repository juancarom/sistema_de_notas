class Admin::StudyPlanSubjectsController < Admin::BaseController
  before_action :set_study_plan_subject, only: [:edit, :update, :destroy]

  def new
    authorize StudyPlanSubject
    @study_plan = StudyPlan.find(params[:study_plan_id])
    @study_plan_subject = StudyPlanSubject.new(study_plan: @study_plan)
    @available_subjects = Subject.order(:name)
  end

  def create
    authorize StudyPlanSubject
    @study_plan_subject = StudyPlanSubject.new(study_plan_subject_params)
    if @study_plan_subject.save
      redirect_to admin_study_plan_path(@study_plan_subject.study_plan), notice: "Materia agregada al plan."
    else
      @study_plan = @study_plan_subject.study_plan
      @available_subjects = Subject.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @study_plan_subject
    @available_subjects = Subject.order(:name)
  end

  def update
    authorize @study_plan_subject
    if @study_plan_subject.update(study_plan_subject_params)
      redirect_to admin_study_plan_path(@study_plan_subject.study_plan), notice: "Materia actualizada."
    else
      @available_subjects = Subject.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @study_plan_subject
    plan = @study_plan_subject.study_plan
    @study_plan_subject.destroy
    redirect_to admin_study_plan_path(plan), notice: "Materia removida del plan."
  end

  private

  def set_study_plan_subject
    @study_plan_subject = StudyPlanSubject.find(params[:id])
  end

  def study_plan_subject_params
    params.require(:study_plan_subject).permit(:study_plan_id, :subject_id, :year_in_plan)
  end
end
