# frozen_string_literal: true

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get '/webauth/login', to: 'authentication#login', as: 'login'
  get '/webauth/logout', to: 'authentication#logout', as: 'logout'
  get '/test_login/:id', to: 'authentication#test_login', as: 'test_login', param: :id if Rails.env.test?

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  get 'fast', to: 'fast#show', defaults: { format: 'html' }
  get 'orcid', to: 'orcid#search'

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resources :collections, only: %i[new create show edit update], param: :druid do
    collection do
      get 'wait/:id', to: 'collections#wait', as: 'wait', param: :id
    end

    member do
      get 'works', to: 'collections#works', as: 'works'
      get 'history', to: 'collections#history', as: 'history'
    end

    namespace :admin do
      resources :delete, only: %i[new destroy], controller: 'delete_collection', param: :collection_druid
    end
  end

  direct :collection_or_wait do |model, options|
    if model.druid
      route_for(:collection, model.druid, options)
    else
      route_for(:wait_collections, model.id, options)
    end
  end

  resources :works, only: %i[new create show edit update destroy], param: :druid do
    collection do
      get 'wait/:id', to: 'works#wait', as: 'wait', param: :id
    end

    member do
      put 'review', to: 'works#review', as: 'review'
      get 'history', to: 'works#history', as: 'history'
    end

    resources :shares, only: %i[new create]

    namespace :admin do
      resources :move, only: %i[new create], controller: 'move'
      resources :change_owner, only: %i[new create], controller: 'change_owner'
      resources :delete, only: %i[new destroy], controller: 'delete_work', param: :druid
    end
  end

  direct :work_or_wait do |model, options|
    if model.druid
      route_for(:work, model.druid, options)
    else
      route_for(:wait_works, model.id, options)
    end
  end

  resources :contents, only: %i[update show destroy] do
    member do
      get 'show_table', to: 'contents#show_table', as: 'show_table'
    end

    resources :globuses, only: %i[new create] do
      collection do
        get 'uploading', to: 'globuses#uploading', as: 'uploading'
        post 'done_uploading', to: 'globuses#done_uploading', as: 'done_uploading'
        get 'wait', to: 'globuses#wait', as: 'wait'
        post 'cancel', to: 'globuses#cancel', as: 'cancel'
      end
    end
  end

  resources :content_files, only: %i[edit update destroy show] do
    member do
      get 'download', to: 'content_files#download', as: 'download'
    end
  end

  resource :terms, only: :show

  resource :contacts, only: %i[new create]

  get 'accounts/search', to: 'accounts#search'
  get 'accounts/search_user', to: 'accounts#search_user'
  get 'affiliations/search', to: 'affiliations#search'

  get 'dashboard', to: 'dashboard#show'

  namespace :admin do
    get 'dashboard', to: 'dashboard#show'

    resource :users_search, only: :new, controller: :users_search do
      get :search
    end

    resource :collection_search, only: :new, controller: :collection_search do
      get :search
    end

    resource :depositors_search, only: :new, controller: :depositors_search do
      get :search
    end

    resource :druid_search, only: :new, controller: :druid_search do
      get :search
    end

    resources :recent_activity_works, only: :index, param: :days_limit
    resources :recent_activity_collections, only: :index, param: :days_limit

    resource :emulate, only: %i[new create], controller: :emulate

    resource :collection_report, only: %i[new create], controller: :collection_report
    resource :work_report, only: %i[new create], controller: :work_report
  end

  root 'home#show'

  mount MissionControl::Jobs::Engine, at: '/jobs'
end
