require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users, controllers: { registrations: "users/registrations", confirmations: "users/confirmations", sessions: "users/sessions", passwords: "users/passwords" }

  ActiveAdmin.routes(self)
    authenticate :admin_user, lambda { |admin| admin.present? } do
      mount Sidekiq::Web => '/sidekiq'
    end

  root to: 'pages#index'
end
