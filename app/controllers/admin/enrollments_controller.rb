class Admin::EnrollmentsController < Admin::BaseController
  before_action :set_enrollment, only: [:show, :edit, :update, :destroy, :enroll_subject, :unenroll_subject]

  def index
    @enrollments = policy_scope(Enrollment)
                     .includes(:user, :course)
                     .order(:academic_year, "users.surname", "users.name")
    @enrollments = @enrollments.where(academic_year: params[:year]) if params[:year].present?
    @enrollments = @enrollments.where(course_id: params[:course_id]) if params[:course_id].present?
    @courses = Course.joins(:study_plan).where(study_plans: { school: current_school }).order(:name)
    @years = Enrollment.where(school: current_school).distinct.pluck(:academic_year).sort.reverse
  end

  def show
    authorize @enrollment
    @transcript = @enrollment.transcript
    @subject_enrollments = @enrollment.subject_enrollments.includes(:subject) if @enrollment.course_id.nil?
  end

  def new
    authorize Enrollment
    @enrollment = Enrollment.new(academic_year: Date.today.year)
    @courses = Course.joins(:study_plan).where(study_plans: { school: current_school }).order(:name)
    @users_for_select = User.joins(:user_role_schools)
                            .where(user_role_schools: { school: current_school, role: :student })
                            .distinct.order(:surname, :name)
  end

  def create
    authorize Enrollment
    student = User.find(params[:enrollment][:user_id])
    course  = Course.find_by(id: params[:enrollment][:course_id])
    year    = params[:enrollment][:academic_year].to_i

    svc = EnrollmentService.new(user: student, school: current_school, academic_year: year)
    @enrollment = svc.enroll_in_course(course)

    redirect_to admin_enrollment_path(@enrollment), notice: "Matrícula creada."
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = e.message
    @courses = Course.joins(:study_plan).where(study_plans: { school: current_school }).order(:name)
    @users_for_select = User.joins(:user_role_schools)
                            .where(user_role_schools: { school: current_school, role: :student })
                            .distinct.order(:surname, :name)
    @enrollment = Enrollment.new
    render :new, status: :unprocessable_entity
  end

  def edit
    authorize @enrollment
    @courses = Course.joins(:study_plan).where(study_plans: { school: current_school }).order(:name)
  end

  def update
    authorize @enrollment
    if @enrollment.update(enrollment_update_params)
      redirect_to admin_enrollment_path(@enrollment), notice: "Matrícula actualizada."
    else
      @courses = Course.joins(:study_plan).where(study_plans: { school: current_school }).order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @enrollment
    @enrollment.discard
    redirect_to admin_enrollments_path, notice: "Matrícula desactivada."
  end

  def bulk_transfer
    authorize Enrollment, :bulk_transfer?
    ids        = params[:enrollment_ids].to_a
    new_course = Course.joins(:study_plan).where(study_plans: { school: current_school }).find(params[:course_id])
    EnrollmentService.new(school: current_school, academic_year: Date.today.year).bulk_transfer(ids, new_course)
    redirect_to admin_enrollments_path, notice: "#{ids.size} matrículas transferidas."
  end

  def enroll_subject
    authorize @enrollment, :enroll_subject?
    subject = Subject.find(params[:subject_id])
    svc = EnrollmentService.new(user: @enrollment.user, school: current_school, academic_year: @enrollment.academic_year)
    svc.enroll_in_subject(subject)
    redirect_to admin_enrollment_path(@enrollment), notice: "Inscripto en #{subject.name}."
  end

  def unenroll_subject
    authorize @enrollment, :unenroll_subject?
    SubjectEnrollment.find_by!(enrollment: @enrollment, subject_id: params[:subject_id]).destroy
    redirect_to admin_enrollment_path(@enrollment), notice: "Desinscripto."
  end

  private

  def set_enrollment
    @enrollment = policy_scope(Enrollment).find(params[:id])
  end

  def enrollment_update_params
    params.require(:enrollment).permit(:course_id, :status)
  end
end
