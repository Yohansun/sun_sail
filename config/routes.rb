require 'sidekiq/web'

MagicOrders::Application.routes.draw do
  get "callbacks/jingdong"
  get '/autologin', to: 'users#autologin'
  devise_for :users, :path => '', :path_names => {:sign_in => 'login'}

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
    end
  end

  resources :products do
    get :change_status
  end

  resources :users
  resources :areas

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
    resources :trade_sources
  end

  mount Sidekiq::Web => '/sidekiq'

  root to: "home#dashboard"
  match "*path", to: "home#index"
end