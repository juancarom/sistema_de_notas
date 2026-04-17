class SchoolSettingsPolicy < ApplicationPolicy
  def show?   = admin?
  def edit?   = admin?
  def update? = admin?
end
