class DashboardPolicy < ApplicationPolicy
  def show?
    roles.any?
  end
end
