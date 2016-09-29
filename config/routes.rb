require 'sidekiq/web'

Rails.application.routes.draw do
  root 'dashboard#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  devise_for :users

  # get '/upload_inventories_data', to: 'inventories_data_uploads#new'

  resources :inventories_data_uploads, except: :index
  resources :dashboard, only: :index

  resources :accounts, only: %i(index new create)
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end
end
