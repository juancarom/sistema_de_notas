puts "Seeding demo data..."

school = School.find_or_create_by!(subdomain: "demo") do |s|
  s.name          = "Colegio Demo San Martín"
  s.min_grade     = 1.0
  s.max_grade     = 10.0
  s.passing_grade = 6.0
  s.city          = "Buenos Aires"
  s.province      = "CABA"
  s.contact_email = "contacto@demo.com"
  s.active        = true
end

ActsAsTenant.with_tenant(school) do
  admin = User.find_or_create_by!(email: "admin@demo.com") do |u|
    u.name = "Admin"; u.surname = "Demo"
    u.password = u.password_confirmation = "password123"
  end
  UserRoleSchool.find_or_create_by!(user: admin, school: school, role: :admin) { |r| r.valid_from = Date.today }

  principal = User.find_or_create_by!(email: "directivo@demo.com") do |u|
    u.name = "María"; u.surname = "González"
    u.password = u.password_confirmation = "password123"
  end
  UserRoleSchool.find_or_create_by!(user: principal, school: school, role: :principal) { |r| r.valid_from = Date.today }

  teacher = User.find_or_create_by!(email: "docente@demo.com") do |u|
    u.name = "Carlos"; u.surname = "Rodríguez"
    u.password = u.password_confirmation = "password123"
  end
  UserRoleSchool.find_or_create_by!(user: teacher, school: school, role: :teacher) { |r| r.valid_from = Date.today }

  student = User.find_or_create_by!(email: "alumno@demo.com") do |u|
    u.name = "Ana"; u.surname = "Martínez"
    u.password = u.password_confirmation = "password123"
  end
  UserRoleSchool.find_or_create_by!(user: student, school: school, role: :student) { |r| r.valid_from = Date.today }

  plan = StudyPlan.find_or_create_by!(name: "Bachiller con Orientación") do |p|
    p.school = school; p.level = :secondary; p.duration_years = 5
    p.plan_type = "Bachiller"; p.start_year = 2020; p.active = true
  end

  subject_names = ["Matemática", "Lengua y Literatura", "Historia", "Geografía", "Física", "Química"]
  subjects = subject_names.map { |n| Subject.find_or_create_by!(name: n, school: school) { |s| s.active = true } }
  subjects.each { |s| StudyPlanSubject.find_or_create_by!(study_plan: plan, subject: s, year_in_plan: 1) }

  course = Course.find_or_create_by!(name: "1° A", study_plan: plan, academic_year: Date.today.year) do |c|
    c.year_in_plan = 1; c.shift = :morning; c.active = true
  end
  subjects.each { |s| CourseSubject.find_or_create_by!(course: course, subject: s) }

  cs = CourseSubject.find_by!(course: course, subject: subjects.first)
  TeacherAssignment.find_or_create_by!(course_subject: cs, user: teacher, academic_year: Date.today.year) { |ta| ta.active = true }

  [
    { name: "1° Trimestre", position: 1, is_final: false },
    { name: "2° Trimestre", position: 2, is_final: false },
    { name: "3° Trimestre", position: 3, is_final: false },
    { name: "Nota Final",   position: 4, is_final: true  }
  ].each do |attrs|
    GradingInstance.find_or_create_by!(name: attrs[:name], study_plan: plan, academic_year: Date.today.year) do |gi|
      gi.position = attrs[:position]; gi.grade_type = :numeric
      gi.is_final = attrs[:is_final]; gi.enabled = true
    end
  end

  unless Enrollment.exists?(user: student, school: school, academic_year: Date.today.year)
    EnrollmentService.new(user: student, school: school, academic_year: Date.today.year).enroll_in_course(course)
  end
end

puts "Demo school: demo.lvh.me:3002"
puts "Users (password: password123): admin@demo.com | directivo@demo.com | docente@demo.com | alumno@demo.com"
