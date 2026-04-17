class UserPolicy < ApplicationPolicy
  def index?       = admin?
  def show?        = admin?
  def create?      = admin?
  def new?         = create?
  def update?      = admin?
  def edit?        = update?
  def destroy?     = admin?
  def assign_role? = admin?
  def remove_role? = admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      admin? ? scope.all : scope.none
    end

    private

    def admin?
      UserRoleSchool.where(user: user, school: Current.school).active_on.where(role: %w[super_admin admin]).exists?
    end
  end
end
