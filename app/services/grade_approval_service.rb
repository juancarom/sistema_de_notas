class GradeApprovalService
  def self.call(grade)
    new(grade).call
  end

  def initialize(grade)
    @grade = grade
    @instance = grade.grading_instance
    @school = grade.transcript&.enrollment&.school
  end

  def call
    return unless @instance&.is_final?
    return unless @grade.numeric_value.present?
    return unless @school

    approved = @grade.numeric_value >= @school.passing_grade
    @grade.update_column(:approved, approved)

    update_subject_enrollment(approved)
  end

  private

  def update_subject_enrollment(approved)
    enrollment = @grade.transcript.enrollment
    return unless enrollment.study_plan_id.nil? || enrollment.course.study_plan.tertiary?

    SubjectEnrollment
      .find_by(enrollment: enrollment, subject: @grade.subject)
      &.update_columns(status: SubjectEnrollment.statuses[approved ? :passed : :failed])
  end
end
