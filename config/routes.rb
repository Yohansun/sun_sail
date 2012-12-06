require 'sidekiq/web'

MagicOrders::Application.routes.draw do
  resources :trade_reports 
  resources :user_activities do 
    collection do 
      get :refresh
      get :all
    end
  end

  match '/auth/taodan/callback', to: 'taobao_app_tokens#create'

  get "callbacks/jingdong"
  get '/autologin', to: 'users#autologin'
  devise_for :users, :path => '', :path_names => {:sign_in => 'login'}
  get "/stocks", to: 'stocks#home'
  get "/stock_products", to: 'stock_products#index'
  get "/stock_products/search", to: 'stock_products#search'
  get "/sales/add_node", to: 'sales#add_node'

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
      get :info
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
      get :logistic_templates
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

  get "/sales/area_analysis", to: 'sales#area_analysis'
  get "/sales/time_analysis", to: 'sales#time_analysis'
  get "/sales/product_analysis", to: 'sales#product_analysis'
  get "/sales/price_analysis", to: 'sales#price_analysis'
  get "/sales/real_area_analysis", to: 'sales#real_area_analysis'
  get "/sales/real_time_analysis", to: 'sales#real_time_analysis'
  get "/sales/real_product_analysis", to: 'sales#real_product_analysis'
  get "/sales/real_price_analysis", to: 'sales#real_price_analysis'
  get "/sales/real_frequency_analysis", to: 'sales#real_frequency_analysis'
  get "/sales/frequency_analysis", to: 'sales#frequency_analysis'
  get "/sales/real_univalent_analysis", to: 'sales#real_univalent_analysis'
  get "/sales/univalent_analysis", to: 'sales#univalent_analysis'
  #get "/sales/customer_analysis", to: 'sales#customer_analysis'
  resources :sales

  match '/alerts', to: 'trades#alerts'
  get "trades/new", to: "trades#new"
  get "trades/create", to: "trades#create"
  get "/trades/:id/sellers_info", to: "trades#sellers_info"
  get "/trades/:id/split_trade", to: "trades#split_trade"
  get "/trades/:id/print_deliver_bill", to: "trades#print_deliver_bill"
  get "/trades/print_deliver_bill.:format", to: "trades#print_deliver_bill"
  get "/trades/:id/logistic_info", to: "trades#logistic_info"
  get "/trades/deliver_list", to: "trades#deliver_list"
  get "/trades/setup_logistics", to: 'trades#setup_logistics'
  get "/trades/batch_deliver", to: 'trades#batch_deliver'
  get "/trades/batch-print-deliver", to: 'trades#batch_print_deliver'
  get "/trades/batch-print-logistic", to: 'trades#batch_print_logistic'
  get "/logistic_rates", to: 'logistic_rates#index'

  scope 'api' do
    get "areas", to: "areas#index"

    resources :trades do
      member do
        get :seller_for_area
        get :split_trade
        get :recover
      end

      collection do
        get :notifer
        get :export
      end
    end

    resources :products
  end

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: "home#dashboard"

  match "/app", to: "home#index"
  match "*path", to: "home#index"
end
