class GradingInstance < ApplicationRecord
  belongs_to :study_plan
  has_many :grades, dependent: :restrict_with_error

  delegate :school, to: :study_plan

  enum :grade_type, { numeric: 0, conceptual: 1 }

  validates :name,          presence: true
  validates :academic_year, presence: true, numericality: { only_integer: true }
  validates :grade_type,    presence: true

  def entry_open?
    return false unless enabled?
    return true if entry_open_at.nil? && entry_close_at.nil?
    now = Time.current
    (entry_open_at.nil? || now >= entry_open_at) && (entry_close_at.nil? || now <= entry_close_at)
  end

  def visible_to_teacher?
    return false unless enabled?
    return true if visible_from.nil?
    Time.current >= visible_from && (visible_until.nil? || Time.current <= visible_until)
  end
end
