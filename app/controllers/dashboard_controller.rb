class DashboardController < ApplicationController
  def show
    authorize :dashboard, :show?
    @school = current_school
  end
end
