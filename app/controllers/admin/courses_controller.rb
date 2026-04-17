class Admin::CoursesController < Admin::BaseController
  before_action :set_course, only: [:show, :edit, :update, :destroy, :assign_subjects]

  def index
    @courses = policy_scope(Course)
                 .joins(:study_plan)
                 .where(study_plans: { school: current_school })
                 .includes(:study_plan)
                 .order("study_plans.name, courses.academic_year DESC, courses.year_in_plan, courses.name")
  end

  def show
    authorize @course
    @course_subjects = @course.course_subjects.includes(:subject)
    @teacher_assignments = TeacherAssignment.joins(course_subject: :course)
                                             .where(course_subjects: { course: @course })
                                             .includes(:user, course_subject: :subject)
    @available_teachers = User.joins(:user_role_schools)
                              .where(user_role_schools: { school: current_school, role: :teacher })
                              .where(user_role_schools: UserRoleSchool.active_on)
                              .distinct
                              .order(:surname, :name)
  end

  def new
    authorize Course
    @course = Course.new(study_plan_id: params[:study_plan_id])
    @study_plans = StudyPlan.order(:name)
  end

  def create
    authorize Course
    @course = Course.new(course_params)
    if @course.save
      redirect_to admin_course_path(@course), notice: "Curso creado."
    else
      @study_plans = StudyPlan.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @course
    @study_plans = StudyPlan.order(:name)
  end

  def update
    authorize @course
    if @course.update(course_params)
      redirect_to admin_course_path(@course), notice: "Curso actualizado."
    else
      @study_plans = StudyPlan.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @course
    @course.destroy
    redirect_to admin_courses_path, notice: "Curso eliminado."
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to admin_course_path(@course), alert: "No se puede eliminar: tiene matrículas asociadas."
  end

  def assign_subjects
    authorize @course
    subject_ids = params[:subject_ids].to_a.map(&:to_i).uniq
    existing = @course.course_subjects.pluck(:subject_id)
    to_add = subject_ids - existing
    to_remove = existing - subject_ids
    to_add.each    { |sid| CourseSubject.find_or_create_by!(course: @course, subject_id: sid) }
    to_remove.each { |sid| @course.course_subjects.find_by(subject_id: sid)&.destroy }
    redirect_to admin_course_path(@course), notice: "Materias actualizadas."
  end

  private

  def set_course
    @course = Course.joins(:study_plan)
                    .where(study_plans: { school_id: current_school.id })
                    .find(params[:id])
  end

  def course_params
    params.require(:course).permit(:name, :year_in_plan, :shift, :academic_year, :active, :study_plan_id)
  end
end
