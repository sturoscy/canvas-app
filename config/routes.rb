CanvasApp::Application.routes.draw do

  # Root of Applications
  root to: 'static_pages#home'

  # Concerns
  concern :assignments do resources :assignments end
  concern :courses do resources :courses end
  concern :groups do resources :groups end
  concern :group_categories do resources :group_categories end
  concern :memberships do resources :memberships end
  concern :sections do resources :sections end
  concern :synced_groups do resources :synced_groups end
  concern :users do resources :users end

  # ActiveResource Routes
  resources :accounts, concerns: [:courses, :users]
  resources :assignments
  resources :courses do
    resources :groups
    resources :group_categories do 
      resources :groups, concerns: [:memberships, :users]
    end
    resources :assignments do
      resources :overrides
    end
    resources :sections, :users
  end
  resources :group_categories do
    resources :groups, concerns: [:memberships, :users] do 
      get 'export_csv', on: :collection
    end
    resources :users
  end
  resources :groups, concerns: [:memberships, :users]
  resources :users

  # Local synced group categories and groups
  resources :synced_group_categories, concerns: [:synced_groups]
  resources :synced_groups

  # Additional Routes
  # Appointment Groups
  resources :appointment_groups, :only => [:index, :show], concerns: [:users]
  match '/appointment_groups/pdf', to: 'appointment_groups#pdf', via: [:post]

  # User Related
  match '/users/masquerade',  to: 'users#masquerade', via: [:post]
  get   'user_search',        to: 'application#user_search'

  # Override Section Data
  match '/overrides/section_data', to: 'overrides#section_data', via: [:get]

end
