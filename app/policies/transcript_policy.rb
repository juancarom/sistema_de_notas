class TranscriptPolicy < ApplicationPolicy
  def index?  = true
  def show?   = own_transcript? || staff_access?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if admin_or_staff?
        scope.all
      elsif student?
        scope.joins(:enrollment).where(enrollments: { user_id: user.id })
      else
        scope.none
      end
    end

    private

    def admin_or_staff?
      UserRoleSchool.where(user: user, school: Current.school).active_on
                    .where(role: %w[super_admin admin principal student_office teacher proctor]).exists?
    end

    def student?
      UserRoleSchool.where(user: user, school: Current.school).active_on.where(role: "student").exists?
    end
  end

  private

  def own_transcript?
    record.enrollment.user_id == user.id
  end

  def staff_access?
    student_office? || principal? || admin? || proctor?
  end
end
