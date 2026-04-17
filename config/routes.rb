Rails.application.routes.draw do
  devise_for :users,
    path: "",
    path_names: { sign_in: "login", sign_out: "logout", password: "clave" },
    controllers: { sessions: "auth/sessions" }

  root to: "dashboard#show"

  namespace :admin do
    resource  :school_settings, only: [:show, :edit, :update]

    resources :users do
      member do
        post :assign_role
        delete "roles/:role", to: "users#remove_role", as: :remove_role
      end
    end

    resources :subjects

    resources :study_plans do
      resources :study_plan_subjects, shallow: true
    end

    resources :courses do
      member { post :assign_subjects }
      resources :teacher_assignments, only: [:index, :create, :destroy]
    end

    resources :grading_instances do
      member { patch :toggle_enabled }
    end

    resources :enrollments do
      collection { post :bulk_transfer }
      member do
        post   :enroll_subject
        delete :unenroll_subject
      end
    end
  end

  namespace :teachers do
    resources :courses, only: [:index, :show] do
      member { get :grade_sheet }
    end
    resources :grades, only: [:create, :update]
  end

  namespace :students do
    resources :transcripts, only: [:index, :show]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
