require 'sidekiq/web'

Rails.application.routes.draw do
  root 'admin/dashboard#index'

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end
    
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
end
