class TeacherAssignmentPolicy < ApplicationPolicy
  def index?   = student_office?
  def create?  = student_office?
  def destroy? = student_office?

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless student_office?
      scope.joins(course_subject: { course: :study_plan })
           .where(study_plans: { school_id: Current.school.id })
    end

    private

    def student_office?
      UserRoleSchool.where(user: user, school: Current.school).active_on
                    .where(role: %w[super_admin admin principal student_office]).exists?
    end
  end
end
