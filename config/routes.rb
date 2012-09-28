require 'sidekiq/web'

MagicOrders::Application.routes.draw do
  get "callbacks/jingdong"
  get '/autologin', to: 'users#autologin'
  devise_for :users, :path => '', :path_names => {:sign_in => 'login'}
  get "/stocks", to: 'stocks#home'

  resources :sellers do
    resources :stocks
    resources :stock_products do
      resources :stock_history
    end

    member do
      get :change_stock_type
      get :children
      get :status_update
    end

    collection do
      post :search
      post :user_list
      get :seller_user
      get :seller_user_list
      get :remove_seller_user
      get :seller_area
      get :create_seller_area
      get :remove_seller_area
    end
  end

  resources :products do
    collection do
      get :fetch_products
    end
    get :change_status
  end

  resources :users
  resources :areas
  resources :trade_sources

  get "trades/new", to: "trades#new"
  get "trades/create", to: "trades#create"

  scope 'api' do
    get '/areas', to: 'areas#index'

    resources :trades do
      member do
        get :seller_for_area
      end

      collection do
        get :notifer
      end
    end

    resources :products
  end

  mount Sidekiq::Web => '/sidekiq'

  root to: "home#dashboard"
  match "*path", to: "home#index"
end