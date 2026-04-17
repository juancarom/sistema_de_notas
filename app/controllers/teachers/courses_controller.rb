class Teachers::CoursesController < Teachers::BaseController
  def index
    if current_user_has_role?(:admin, :principal)
      @courses = Course.joins(:study_plan)
                       .where(study_plans: { school: current_school })
                       .includes(:study_plan)
                       .order(:academic_year, :name)
    else
      @courses = Course.joins(:study_plan, course_subjects: :teacher_assignments)
                       .where(teacher_assignments: { user: current_user })
                       .where(study_plans: { school_id: current_school.id })
                       .distinct
                       .includes(:study_plan)
                       .order(:academic_year, :name)
    end
  end

  def show
    authorize @course = find_course
    @course_subjects = @course.course_subjects
                               .joins(:teacher_assignments)
                               .where(teacher_assignments: { user: current_user })
                               .includes(:subject)
    @course_subjects = @course.course_subjects.includes(:subject) if current_user_has_role?(:admin, :principal)
  end

  def grade_sheet
    authorize @course = find_course, :show?
    @subject    = Subject.find(params[:subject_id]) if params[:subject_id]
    @subject  ||= @course.subjects.first
    @enrollments = @course.enrollments.kept
                          .includes(:user, transcript: :grades)
                          .where(academic_year: @course.academic_year)
                          .order("users.surname", "users.name")
    @grading_instances = GradingInstance.joins(:study_plan)
                                         .where(study_plans: { school: current_school })
                                         .where(study_plan: @course.study_plan,
                                                academic_year: @course.academic_year)
                                         .order(:position)
    @subjects = @course.subjects.order(:name)
  end

  private

  def find_course
    Course.joins(:study_plan)
          .where(study_plans: { school: current_school })
          .find(params[:id])
  end
end
