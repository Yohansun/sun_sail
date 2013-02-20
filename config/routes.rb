require 'sidekiq/web'

MagicOrders::Application.routes.draw do

  resources :upload_files

  resources :bbs_categories
  resources :bbs_topics do
    member do
      get :download
      get :print
    end
    collection do
      get :list
      get :data_download
      get :news
      get :standard_use
    end
  end

  resources :reconcile_statements, only: [:index, :show] do
    member do
      put :audit
    end
    collection do
      get :exports
      put :audits
    end
    resources :reconcile_statement_details, only: [:show] do
      member do
        get :export_detail
      end
    end
  end

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
  devise_for :users, :path => '', :path_names => {:sign_in => 'login'},
    controllers: { sessions: "sessions" }

  get "/stocks", to: 'stocks#home'
  get "/stock_products", to: 'stock_products#index'
  get "/stock_products/search", to: 'stock_products#search'
  get "/sales/add_node", to: 'sales#add_node'
  get "/api/logistics", to: 'logistics#logistic_templates'
  get 'callcenter/wangwang_list', to: 'callcenter#wangwang_list'
  get 'callcenter/remove_wangwang', to: 'callcenter#remove_wangwang'


  resources :colors do
    collection do
      get :autocomplete
    end
  end

  resources :categories
  
  get 'callcenter/contrastive_performance'
  get 'callcenter/inquired_and_created'
  get 'callcenter/created_and_paid'
  get 'callcenter/followed_paid'
  get 'callcenter/settings'
  get 'callcenter/adjust_filter'
  
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

  match '/switch_account/:id', to: 'users#switch_account', as: :switch_account
  resources :users do
    collection do
      post :search
    end
  end    
  
  resources :areas
  resources :trade_sources

  resources :account_setups
  resources :taobao_app_tokens, only: [:create]

  get "/sales/area_analysis", to: 'sales#area_analysis'
  get "/sales/time_analysis", to: 'sales#time_analysis'
  get "/sales/product_analysis", to: 'sales#product_analysis'
  get "/sales/price_analysis", to: 'sales#price_analysis'
  get "/sales/frequency_analysis", to: 'sales#frequency_analysis'
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
  get "/deliver_bills/print_deliver_bill.:format", to: "deliver_bills#print_deliver_bill"
  get "/deliver_bills/:id/logistic_info", to: "deliver_bills#logistic_info"
  get "/deliver_bills/deliver_list", to: "deliver_bills#deliver_list"
  get "/trades/deliver_list", to: "trades#deliver_list"
  get "/deliver_bills/setup_logistics", to: 'deliver_bills#setup_logistics'
  get "/trades/batch_deliver", to: 'trades#batch_deliver'
  get "/deliver_bills/batch-print-deliver", to: 'deliver_bills#batch_print_deliver'
  get "/deliver_bills/batch-print-logistic", to: 'deliver_bills#batch_print_logistic'
  get "/logistic_rates", to: 'logistic_rates#index'
  get "/change_stock_product", to: 'stock_products#change_stock_product'

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
    resources :deliver_bills
  end

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: "home#dashboard"

  match '/go/npsellers', :to => 'go#npsellers'
  match "/app", to: "home#index"
  match "*path", to: "home#index"

end
