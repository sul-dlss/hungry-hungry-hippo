Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get '/webauth/login', to: 'authentication#login', as: 'login'
  get '/webauth/logout', to: 'authentication#logout', as: 'logout'


  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  resources :collections, only: [:new, :create, :show, :edit, :update], param: :druid do
    collection do
      get 'wait/:id', to: 'collections#wait', as: 'wait'
    end
  end

  resources :works, only: [:new, :create, :show, :edit, :update, :destroy], param: :druid do
    collection do
      get 'wait/:id', to: 'works#wait', as: 'wait'
    end
  end

  resources :contents, only: [:edit, :update, :show] do
    member do
      get 'show_table', to: 'contents#show_table', as: 'show_table'
    end
  end

  resources :content_files, only: [:edit, :update, :destroy, :show]

  root to: 'dashboard#show'

  mount MissionControl::Jobs::Engine, at: "/jobs"
end
