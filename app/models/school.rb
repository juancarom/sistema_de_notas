class School < ApplicationRecord
  has_one_attached :logo
  has_one_attached :banner

  has_many :user_role_schools, dependent: :destroy
  has_many :users, through: :user_role_schools
  has_many :study_plans, dependent: :destroy
  has_many :subjects, dependent: :destroy
  has_many :enrollments, dependent: :destroy

  include Discard::Model

  validates :name,         presence: true
  validates :subdomain,    presence: true, uniqueness: true,
                           format: { with: /\A[a-z0-9\-]+\z/, message: "solo letras minúsculas, números y guiones" }
  validates :min_grade,     presence: true, numericality: true
  validates :max_grade,     presence: true, numericality: true
  validates :passing_grade, presence: true, numericality: true
  validate  :grade_scale_consistency

  def tertiary_plan?(study_plan)
    study_plan.tertiary?
  end

  private

  def grade_scale_consistency
    return unless min_grade && passing_grade && max_grade
    errors.add(:passing_grade, "debe ser mayor que la nota mínima") unless passing_grade > min_grade
    errors.add(:passing_grade, "debe ser menor o igual a la nota máxima") unless passing_grade <= max_grade
  end
end
