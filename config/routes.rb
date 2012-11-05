require 'sidekiq/web'

MagicOrders::Application.routes.draw do
  resources :trade_reports

  match '/auth/taodan/callback', to: 'taobao_app_tokens#create'

  get "callbacks/jingdong"
  get '/autologin', to: 'users#autologin'
  devise_for :users, :path => '', :path_names => {:sign_in => 'login'}
  get "/stocks", to: 'stocks#home'
  get "/stock_products", to: 'stock_products#index'
  get "/stock_products/search", to: 'stock_products#search'

  resources :colors do
    collection do
      get :autocomplete
    end
  end

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
      get :latest
      get :closed
    end
  end

  resources :products do
    collection do
      get :fetch_products
    end
    get :change_status
  end

  resources :logistics do
    member do
      get :delete
    end
    collection do
      get :logistic_area
      get :remove_logistic_area
      get :create_logistic_area
      post :user_list
      get :remove_logistic_user
      get :logistic_user
      get :logistic_user_list
    end
  end

  resources :users
  resources :areas
  resources :trade_sources

  match '/alerts', to: 'trades#alerts'
  get "trades/new", to: "trades#new"
  get "trades/create", to: "trades#create"
  get "/trades/:id/sellers_info", to: "trades#sellers_info"
  get "/trades/:id/split_trade", to: "trades#split_trade"
  get "/trades/:id/print_bill", to: "trades#print_bill"

  scope 'api' do
    get "areas", to: "areas#index"

    resources :trades do
      member do
        get :seller_for_area
      end

      collection do
        get :notifer
        get :export
      end
    end

    resources :products
  end

  mount Sidekiq::Web => '/sidekiq'
  mount MailsViewer::Engine => '/delivered_mails'

  root to: "home#dashboard"

  match "/app", to: "home#index"
  match "*path", to: "home#index"
end
