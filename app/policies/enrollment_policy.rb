class EnrollmentPolicy < ApplicationPolicy
  def index?          = student_office?
  def show?           = student_office?
  def create?         = student_office?
  def new?            = create?
  def update?         = student_office?
  def edit?           = update?
  def destroy?        = student_office?
  def bulk_transfer?  = student_office?
  def enroll_subject? = student_office?
  def unenroll_subject? = student_office?

  class Scope < ApplicationPolicy::Scope
    def resolve = student_office? ? scope.all : scope.none

    private

    def student_office?
      UserRoleSchool.where(user: user, school: Current.school).active_on
                    .where(role: %w[super_admin admin principal student_office]).exists?
    end
  end
end
