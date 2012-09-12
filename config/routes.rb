require 'sidekiq/web'

MagicOrders::Application.routes.draw do

  get "callbacks/jingdong"
  get 'autologin', to: 'users#autologin'
  devise_for :users, :path => '', :path_names => {:sign_in => 'login'}

  scope 'api' do
    resources :trades do
      collection do
        get :notifer
      end
    end

    resources :sellers do
      member do
        get :children
      end
    end

    resources :users
    resources :trade_sources
    resources :areas do
      collection do
        get :export
        get :autocomplete
        match :area_search
        match :remap_sellers
      end
    end
  end

  mount Sidekiq::Web => '/sidekiq'

  root to: "home#dashboard"
  match "*path", to: "home#index"

end