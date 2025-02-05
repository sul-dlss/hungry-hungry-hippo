# frozen_string_literal: true

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get '/webauth/login', to: 'authentication#login', as: 'login'
  get '/webauth/logout', to: 'authentication#logout', as: 'logout'

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
      get 'wait/:id', to: 'collections#wait', as: 'wait'
    end
  end

  resources :works, only: %i[new create show edit update destroy], param: :druid do
    collection do
      get 'wait/:id', to: 'works#wait', as: 'wait'
    end

    member do
      put 'review', to: 'works#review', as: 'review'
    end
  end

  resources :contents, only: %i[update show] do
    member do
      get 'show_table', to: 'contents#show_table', as: 'show_table'
    end
  end

  resources :content_files, only: %i[edit update destroy show]

  # This route is used by the emails for the contact the SDR team link.
  direct :contact_form do
    { controller: 'home', action: 'show', anchor: 'help' }
  end

  resource :terms, only: :show

  resource :contacts, only: %i[new create] do
    member do
      get 'success', to: 'contacts#success'
    end
  end

  get 'dashboard', to: 'dashboard#show'

  root 'home#show'

  mount MissionControl::Jobs::Engine, at: '/jobs'
end
