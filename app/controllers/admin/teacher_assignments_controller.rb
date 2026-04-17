class Admin::TeacherAssignmentsController < Admin::BaseController
  before_action :set_course

  def index
    @teacher_assignments = policy_scope(TeacherAssignment).joins(course_subject: :course)
                                             .where(course_subjects: { course: @course })
                                             .includes(:user, course_subject: :subject)
  end

  def create
    authorize TeacherAssignment
    cs = CourseSubject.find(params[:teacher_assignment][:course_subject_id])
    ta = TeacherAssignment.find_or_initialize_by(
      course_subject: cs,
      user_id: params[:teacher_assignment][:user_id],
      academic_year: params[:teacher_assignment][:academic_year] || Date.today.year
    )
    ta.active = true
    if ta.save
      redirect_to admin_course_path(@course), notice: "Docente asignado."
    else
      redirect_to admin_course_path(@course), alert: ta.errors.full_messages.to_sentence
    end
  end

  def destroy
    authorize TeacherAssignment
    ta = TeacherAssignment.joins(course_subject: :course)
                          .where(course_subjects: { course: @course })
                          .find(params[:id])
    ta.destroy
    redirect_to admin_course_path(@course), notice: "Docente desvinculado."
  end

  private

  def set_course
    @course = Course.joins(:study_plan).where(study_plans: { school: current_school }).find(params[:course_id])
  end
end
