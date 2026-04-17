# Sistema de Notas Educación — Estado del Desarrollo

## Stack tecnológico

| Tecnología | Versión | Propósito |
|---|---|---|
| Ruby | 3.3.x | Lenguaje |
| Rails | 8.1.3 | Framework |
| PostgreSQL | 16 | Base de datos |
| Hotwire (Turbo + Stimulus) | Rails 8 built-in | Frontend reactivo |
| TailwindCSS | v4 (tailwindcss-rails 4.x) | Estilos |
| Devise | 4.9 | Autenticación |
| Pundit | 2.3 | Autorización |
| acts_as_tenant | 0.6 | Multi-tenancy por subdominio |
| Discard | 1.3 | Soft delete |
| Kamal | 2.x | Deploy a producción |

## Entorno de desarrollo — Comandos esenciales

```bash
# Iniciar base de datos (la primera vez)
docker compose up db -d

# Iniciar servidor Rails (puerto 3002 en el host)
docker compose up web -d

# Ver logs
docker compose logs web -f

# Parar todo
docker compose down

# Acceder a la consola Rails
docker compose run --rm web bundle exec rails console

# Correr migraciones
docker compose run --rm web bundle exec rails db:migrate

# Cargar datos de prueba
docker compose run --rm web bundle exec rails db:seed

# Reconstruir CSS (cuando cambian los estilos)
docker compose run --rm web bundle exec rails tailwindcss:build

# Instalar nuevas gems
docker compose run --rm --no-deps web bundle install
```

## Acceso local

La app usa subdominio para identificar la institución.
- **URL base**: `http://demo.lvh.me:3002`
  - `lvh.me` resuelve a `127.0.0.1` automáticamente
  - El subdominio `demo` se mapea a la escuela "Colegio Demo San Martín"

## Usuarios de prueba (datos de seeds)

| Email | Contraseña | Rol |
|---|---|---|
| admin@demo.com | password123 | Admin |
| directivo@demo.com | password123 | Directivo |
| docente@demo.com | password123 | Docente |
| alumno@demo.com | password123 | Estudiante |

---

## Base de datos — Tablas creadas

Todas las migraciones corrieron exitosamente. Tablas en orden de dependencia:

1. `active_storage_blobs` / `active_storage_attachments` — Para logo/banner de escuela
2. `users` — Devise + campos personales (name, surname, dni, birth_date, phone, address, city)
3. `schools` — Instituciones educativas (subdomain, min/max/passing_grade, dirección, contacto)
4. `user_role_schools` — Roles por usuario por escuela (con valid_from/valid_until)
5. `study_plans` — Planes de estudio (level, duration_years, plan_type)
6. `subjects` — Materias reutilizables a nivel escuela
7. `study_plan_subjects` — Join: materia + plan + año (year_in_plan)
8. `courses` — Cursos (ej: "1° A") perteneciente a un plan
9. `course_subjects` — Materias que se dictan en un curso
10. `teacher_assignments` — Asignación de docentes a materias de cursos
11. `grading_instances` — Instancias de calificación (1° Trimestre, Final, etc.)
12. `enrollments` — Matrículas de alumnos (con course_id opcional para terciario)
13. `subject_enrollments` — Inscripciones por materia (solo terciario)
14. `transcripts` — Analíticos (1 por matrícula por año)
15. `grades` — Notas (numeric_value o conceptual_value, con approved flag)

## Modelos creados

| Modelo | Archivo | Notas |
|---|---|---|
| School | app/models/school.rb | `has_one_attached :logo/banner`, Discard |
| User | app/models/user.rb | Devise + Discard |
| UserRoleSchool | app/models/user_role_school.rb | Roles con vigencia temporal |
| StudyPlan | app/models/study_plan.rb | `acts_as_tenant :school` |
| Subject | app/models/subject.rb | `acts_as_tenant :school` |
| StudyPlanSubject | app/models/study_plan_subject.rb | Join: plan + materia + año |
| Course | app/models/course.rb | Pertenece a study_plan (sin acts_as_tenant directo) |
| CourseSubject | app/models/course_subject.rb | Join: curso + materia |
| TeacherAssignment | app/models/teacher_assignment.rb | Docente asignado a course_subject |
| GradingInstance | app/models/grading_instance.rb | Instancias con ventanas de carga |
| Enrollment | app/models/enrollment.rb | `acts_as_tenant :school`, Discard |
| SubjectEnrollment | app/models/subject_enrollment.rb | Solo para terciario |
| Transcript | app/models/transcript.rb | Analítico (ancla de notas) |
| Grade | app/models/grade.rb | Con callback a GradeApprovalService |
| Current | app/models/current.rb | `CurrentAttributes`: school + user |

## Servicios creados

- `app/services/enrollment_service.rb` — Matriculación (no terciario + terciario + bulk transfer)
- `app/services/grade_approval_service.rb` — Setea `approved` cuando instancia es `is_final`

## Roles del sistema

| Código | UI Label | Puede hacer |
|---|---|---|
| `super_admin` | Super Admin | Todo, cross-school |
| `admin` | Admin | Todo dentro de la escuela |
| `principal` | Directivo | Gestión académica, habilitar instancias |
| `student_office` | Oficina de Alumnos | Matrículas, inscripciones |
| `teacher` | Docente | Cargar notas en materias asignadas |
| `aide` | Auxiliar | Solo lectura |
| `proctor` | Preceptor | Ver alumnos y analítico |
| `student` | Estudiante | Solo su analítico |

---

## Lo que está construido (MVP — Iteración 1)

### ✅ Infraestructura
- [x] Docker setup (Dockerfile multi-stage: dev + prod, docker-compose.yml)
- [x] Rails 8.1.3 app con PostgreSQL + Hotwire + TailwindCSS v4
- [x] Base de datos con todas las tablas y constraints
- [x] Multi-tenancy por subdominio (acts_as_tenant + TenantScoped concern)
- [x] Kamal configurado para deploy a `157.230.0.32` (falta completar: dominio + Docker Hub username)

### ✅ Auth & Roles
- [x] Devise instalado y configurado
- [x] Modelo User con campos personales
- [x] UserRoleSchool con roles + vigencia temporal
- [x] `Current.school` y `Current.user` disponibles en toda la app
- [x] `ApplicationPolicy` (Pundit) con helpers de rol
- [x] `DashboardPolicy`

### ✅ Modelos de dominio
- [x] Todos los modelos creados con validaciones y asociaciones
- [x] EnrollmentService (terciario y no terciario)
- [x] GradeApprovalService

### ✅ Vistas básicas
- [x] Layout principal con navbar
- [x] Layout de auth (login)
- [x] Dashboard role-aware
- [x] Vistas Devise generadas (sessions/new, etc.)

### ✅ Rutas
- [x] `namespace :admin` con todos los recursos
- [x] `namespace :teachers` (courses + grades)
- [x] `namespace :students` (transcripts)

### ✅ Seeds
- [x] Escuela demo, usuarios, plan de estudio, curso, materias, instancias, matrícula

---

## Lo que FALTA construir

### 🔴 Prioritario (sin esto no funciona el flujo básico)

1. **Login customizado** — Las vistas Devise generadas necesitan estilo Tailwind y ser conscientes del subdominio. El formulario de login debe mostrar el logo de la escuela.
   - Archivo: `app/views/devise/sessions/new.html.erb`
   - Usar layout `:auth`

2. **Admin — Gestión de usuarios y roles**
   - `Admin::UsersController` (CRUD + assign/remove roles)
   - Vistas con SimpleForm

3. **Admin — Planes de estudio y materias**
   - `Admin::StudyPlansController`
   - `Admin::SubjectsController`
   - `Admin::StudyPlanSubjectsController` (ligar materias al plan con año)

4. **Admin — Cursos y asignación de docentes**
   - `Admin::CoursesController`
   - `Admin::TeacherAssignmentsController` (link/unlink docentes a materias)

5. **Admin — Instancias de calificación**
   - `Admin::GradingInstancesController` (CRUD + toggle_enabled via Turbo Stream)

6. **Admin — Matrículas**
   - `Admin::EnrollmentsController` (inscribir alumnos, bulk transfer entre cursos)

7. **Docentes — Planilla de notas**
   - `Teachers::CoursesController` (ver cursos asignados)
   - `Teachers::GradesController` (grade_sheet: grilla alumnos × instancias, entry via Turbo Frames)

8. **Estudiantes — Analítico**
   - `Students::TranscriptsController#show` (tabla materias × instancias)

9. **Pundit Policies** — Falta implementar todas las policies:
   - `StudyPlanPolicy`, `SubjectPolicy`, `CoursePolicy`
   - `GradingInstancePolicy`, `EnrollmentPolicy`
   - `GradePolicy` (con check: instancia habilitada + ventana abierta + docente asignado)
   - `TranscriptPolicy`

10. **Config de Devise** — Desactivar registración pública (solo admin crea usuarios):
    - En `config/initializers/devise.rb`: deshabilitar `:registerable`
    - En `app/models/user.rb`: quitar `:registerable` de devise
    - Agregar `config.sign_out_via = :delete`

### 🟡 Importante pero puede esperar una sesión

11. **School settings admin** — `Admin::SchoolSettingsController` (editar escala de notas, upload de logo/banner)

12. **Configuración de Devise para subdominios** — El `after_sign_in_path_for` y el manejo del subdominio en Devise sessions necesita ajuste fino.

13. **RSpec setup** — `spec/rails_helper.rb` configurar FactoryBot, Shoulda, Pundit matchers, Capybara.

14. **Seeds de producción** — Separar seeds en `db/seeds/production.rb` y `db/seeds/development.rb`.

### 🟢 Iteración 2 (no urgente)

- Google OAuth (OmniAuth)
- Super admin cross-school panel
- PDF del analítico (Prawn o Grover)
- Email notifications (Action Mailer + Solid Queue)
- Reportes y estadísticas

---

## Deploy a producción (DigitalOcean `157.230.0.32`)

### Configuración pendiente antes del primer deploy

1. **Editar `config/deploy.yml`**:
   - Reemplazar `YOUR_DOCKERHUB_USERNAME` con tu usuario de Docker Hub
   - Reemplazar `YOUR_DOMAIN` con el dominio apuntando a `157.230.0.32`

2. **Variables de entorno** (exportar antes de `kamal deploy`):
   ```bash
   export KAMAL_REGISTRY_PASSWORD=<tu_password_de_dockerhub>
   export SISTEMA_NOTAS_DB_PASSWORD=<password_seguro_para_postgres>
   ```

3. **Primer deploy**:
   ```bash
   # Desde el directorio del proyecto (NO dentro de Docker)
   bundle exec kamal setup    # Solo la primera vez — instala Docker en el servidor
   bundle exec kamal deploy   # Deploya la app
   bundle exec kamal app exec 'rails db:migrate'
   bundle exec kamal app exec 'rails db:seed'
   ```

4. **Para deploys posteriores**:
   ```bash
   bundle exec kamal deploy
   ```

5. **Logs en producción**:
   ```bash
   kamal app logs -f
   ```

---

## Arquitectura de multi-tenancy

Cada institución accede por subdominio: `nombreescuela.dominio.com`

El `TenantScoped` concern (en `app/controllers/concerns/tenant_scoped.rb`):
1. Lee `request.subdomain`
2. Busca `School.kept.find_by(subdomain: subdomain)`
3. Setea `ActsAsTenant.current_tenant = school`
4. Setea `Current.school = school`

Todos los modelos con `acts_as_tenant :school` filtran automáticamente sus queries al school actual.

**Para testing local**: usar `demo.lvh.me:3002` (lvh.me resuelve a 127.0.0.1).
**Para agregar una escuela**: crear un `School` con el subdominio deseado.

---

## Estructura de archivos clave

```
app/
├── controllers/
│   ├── application_controller.rb     ← TenantScoped + Pundit + authenticate_user!
│   ├── concerns/tenant_scoped.rb     ← Detecta escuela desde subdominio
│   ├── auth/sessions_controller.rb   ← Override Devise, usa layout :auth
│   └── dashboard_controller.rb       ← Home role-aware
├── models/
│   ├── current.rb                    ← Current.school / Current.user
│   └── user_role_school.rb           ← ROLE_LABELS hash para UI
├── policies/
│   └── application_policy.rb         ← Helpers: admin?, teacher?, student?, etc.
├── services/
│   ├── enrollment_service.rb
│   └── grade_approval_service.rb
└── views/
    ├── layouts/application.html.erb
    ├── layouts/auth.html.erb
    ├── shared/_navbar.html.erb
    └── dashboard/show.html.erb
config/
├── routes.rb                         ← namespaces: admin, teachers, students
├── deploy.yml                        ← Kamal: falta dominio + registry username
└── environments/development.rb       ← mailer default_url_options para lvh.me:3002
```
