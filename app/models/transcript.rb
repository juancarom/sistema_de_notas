class Transcript < ApplicationRecord
  belongs_to :enrollment
  has_many   :grades, dependent: :destroy
  has_one    :user,   through: :enrollment
  has_one    :school, through: :enrollment

  validates :academic_year, presence: true, numericality: { only_integer: true }
  validates :enrollment_id, uniqueness: { scope: :academic_year }

  def locked?
    locked
  end
end
