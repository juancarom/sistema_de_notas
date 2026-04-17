class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :assign_role, :remove_role]

  def index
    @users = policy_scope(User)
               .joins(:user_role_schools)
               .where(user_role_schools: { school: current_school })
               .distinct
               .order(:surname, :name)
    @users = @users.where("users.name ILIKE ? OR users.surname ILIKE ? OR users.email ILIKE ?",
                           "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
  end

  def show
    authorize @user
    @roles = @user.user_role_schools.where(school: current_school).order(:role)
  end

  def new
    authorize User
    @user = User.new
  end

  def create
    authorize User
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_user_path(@user), notice: "Usuario creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @user
  end

  def update
    authorize @user
    params_to_use = user_params
    params_to_use = params_to_use.except(:password, :password_confirmation) if params_to_use[:password].blank?
    if @user.update(params_to_use)
      redirect_to admin_user_path(@user), notice: "Usuario actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user
    @user.discard
    redirect_to admin_users_path, notice: "Usuario desactivado."
  end

  def assign_role
    authorize @user, :assign_role?
    role  = params[:role]
    valid = UserRoleSchool.roles.keys.include?(role)
    if valid
      urs = UserRoleSchool.find_or_initialize_by(user: @user, school: current_school, role: role)
      urs.valid_from ||= Date.today
      urs.save!
      redirect_to admin_user_path(@user), notice: "Rol asignado."
    else
      redirect_to admin_user_path(@user), alert: "Rol inválido."
    end
  end

  def remove_role
    authorize @user, :remove_role?
    UserRoleSchool.where(user: @user, school: current_school, role: params[:role]).destroy_all
    redirect_to admin_user_path(@user), notice: "Rol removido."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :surname, :email, :dni, :birth_date, :phone, :address, :city,
                                  :password, :password_confirmation)
  end
end
