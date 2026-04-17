class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable
  # :registerable deliberately excluded — only admins create users

  include Discard::Model

  has_many :user_role_schools, dependent: :destroy
  has_many :schools, through: :user_role_schools
  has_many :enrollments, dependent: :restrict_with_error
  has_many :grades, foreign_key: :user_id, dependent: :restrict_with_error
  has_many :entered_grades, class_name: "Grade", foreign_key: :entered_by_id
  has_many :teacher_assignments, dependent: :destroy

  validates :name,    presence: true
  validates :surname, presence: true

  def full_name
    "#{surname}, #{name}"
  end

  def display_name
    "#{name} #{surname}"
  end

  def role_at(school)
    user_role_schools.active_on.where(school: school).pluck(:role)
  end

  def has_role_at?(role, school)
    user_role_schools.active_on.exists?(school: school, role: UserRoleSchool.roles[role])
  end
end
