class StudyPlanPolicy < ApplicationPolicy
  def index?   = principal?
  def show?    = principal?
  def create?  = principal?
  def new?     = create?
  def update?  = principal?
  def edit?    = update?
  def destroy? = admin?

  class Scope < ApplicationPolicy::Scope
    def resolve = principal? ? scope.all : scope.none

    private

    def principal?
      UserRoleSchool.where(user: user, school: Current.school).active_on
                    .where(role: %w[super_admin admin principal]).exists?
    end
  end
end
