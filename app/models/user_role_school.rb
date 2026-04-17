class UserRoleSchool < ApplicationRecord
  belongs_to :user
  belongs_to :school

  enum :role, {
    super_admin:    0,
    admin:          1,
    principal:      2,
    student_office: 3,
    teacher:        4,
    aide:           5,
    proctor:        6,
    student:        7
  }

  validates :role,       presence: true
  validates :valid_from, presence: true
  validates :role, uniqueness: { scope: [:user_id, :school_id], message: "ya tiene este rol en la institución" }

  scope :active_on, ->(date = Date.today) {
    where("valid_from <= ? AND (valid_until IS NULL OR valid_until >= ?)", date, date)
  }

  ROLE_LABELS = {
    "super_admin"    => "Super Admin",
    "admin"          => "Admin",
    "principal"      => "Directivo",
    "student_office" => "Oficina de Alumnos",
    "teacher"        => "Docente",
    "aide"           => "Auxiliar",
    "proctor"        => "Preceptor",
    "student"        => "Estudiante"
  }.freeze

  def label
    ROLE_LABELS[role]
  end
end
