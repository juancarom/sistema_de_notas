class CoursePolicy < ApplicationPolicy
  def index?   = principal?
  def show?    = principal?
  def create?  = principal?
  def new?     = create?
  def update?  = principal?
  def edit?    = update?
  def destroy? = admin?
  def assign_subjects? = principal?

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless principal?
      scope.joins(:study_plan).where(study_plans: { school_id: Current.school.id })
    end

    private

    def principal?
      UserRoleSchool.where(user: user, school: Current.school).active_on
                    .where(role: %w[super_admin admin principal]).exists?
    end
  end
end
