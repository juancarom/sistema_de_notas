class GradePolicy < ApplicationPolicy
  def index?  = admin? || teacher_assigned?
  def show?   = admin? || teacher_assigned? || own_grade?
  def create? = can_enter_grade?
  def new?    = create?
  def update? = can_enter_grade?
  def edit?   = update?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if admin?
        scope.all
      elsif teacher?
        scope.joins(transcript: { enrollment: { course: :teacher_assignments } })
             .where(teacher_assignments: { user_id: user.id })
      else
        scope.none
      end
    end

    private

    def admin?
      UserRoleSchool.where(user: user, school: Current.school).active_on
                    .where(role: %w[super_admin admin principal student_office]).exists?
    end

    def teacher?
      UserRoleSchool.where(user: user, school: Current.school).active_on.where(role: "teacher").exists?
    end
  end

  private

  def can_enter_grade?
    return false unless record.grading_instance.enabled?
    return false unless record.grading_instance.entry_open?
    return false if record.transcript&.locked?
    teacher_assigned?
  end

  def teacher_assigned?
    return false unless teacher?
    return true if admin?

    grading_instance = record.is_a?(Grade) ? record.grading_instance : record
    subject = record.is_a?(Grade) ? record.subject : nil
    return false unless subject && grading_instance

    TeacherAssignment
      .joins(:course_subject)
      .where(user: user, academic_year: grading_instance.academic_year)
      .where(course_subjects: { subject_id: subject.id })
      .exists?
  end

  def own_grade?
    record.is_a?(Grade) && record.user_id == user.id
  end
end
