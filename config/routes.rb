# frozen_string_literal: true

Rails.application.routes.draw do
  resources :tenants, only: [:show] do
    get 'csv_upload/create'
  end
  resources :properties, only: %i[index show] do
    collection do
      post 'csv_upload', to: 'properties/csv_upload#create'
    end
  end
  resources :tenants, only: [] do
    collection do
      post 'csv_upload', to: 'tenants/csv_upload#create'
    end
  end
  devise_for :accounts

  root 'dashboard#index'
  # TODO: Add root route as needed/necessary
  # unauthenticated :user do
  #   root to: 'static_pages#landing'
  # end
end
