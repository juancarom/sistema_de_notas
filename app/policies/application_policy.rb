class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "Debés iniciar sesión." unless user
    @user = user
    @record = record
  end

  def index?   = false
  def show?    = false
  def create?  = false
  def new?     = create?
  def update?  = false
  def edit?    = update?
  def destroy? = false

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "#{self.class}#resolve no está implementado."
    end

    private

    attr_reader :user, :scope
  end

  private

  def school
    Current.school
  end

  def roles
    @roles ||= UserRoleSchool.where(user: user, school: school).active_on.pluck(:role)
  end

  def super_admin?    = roles.include?("super_admin")
  def admin?          = roles.include?("admin") || super_admin?
  def principal?      = roles.include?("principal") || admin?
  def student_office? = roles.include?("student_office") || principal?
  def teacher?        = roles.include?("teacher")
  def proctor?        = roles.include?("proctor")
  def aide?           = roles.include?("aide")
  def student?        = roles.include?("student")

  def admin_or_above?  = admin?
  def staff?           = principal? || student_office? || teacher? || proctor?
end
