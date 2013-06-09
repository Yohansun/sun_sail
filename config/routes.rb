require 'sidekiq/web'

MagicOrders::Application.routes.draw do
  resources :customers ,:only => [:index] do

    collection do
      get :potential
      get :paid
      get :around
      get :send_messages
      get :get_recipients
      post :invoice_messages
    end
  end

  resources :stock_in_bills do
    post :add_product   , :on => :collection
    post :remove_product, :on => :collection
    post :sync, :on => :collection
    post :check, :on => :collection
    post :rollback, :on => :collection
  end
  resources :stock_out_bills do
    post :add_product   , :on => :collection
    post :remove_product, :on => :collection
    post :sync, :on => :collection
    post :check, :on => :collection
    post :rollback, :on => :collection
  end

  resources :stocks, only: [:index] do
    get :edit_depot,:on => :collection
    put :update_depot,:on => :member
  end
  match "/stocks/safe_stock", to: 'stocks#safe_stock'
  post "/stocks/edit_safe_stock", to: 'stocks#edit_safe_stock'
  match "/stocks/change_product_type", to: 'stocks#change_product_type'

  resources :stock_bills

  wash_out :stock_api

  resources :trade_searches do
    collection do
      get :operations
    end
  end

  resources :logistic_groups
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

  resources :trade_reports do
    get :download, :on => :member
  end
  resources :user_activities do
    collection do
      get :refresh
      get :all
    end
  end

  match '/auth/taodan/callback', to: 'taobao_app_tokens#create'
  match '/test_init', to: 'taobao_app_tokens#test'

  get "callbacks/jingdong"
  get '/autologin', to: 'users#autologin'
  devise_for :users, :path => '', :path_names => {:sign_in => 'login'},
    controllers: { sessions: "sessions" , registrations: "registrations"}

  get "/sales/add_node", to: 'sales#add_node'
  get "/api/logistics", to: 'logistics#logistic_templates'
  get 'callcenter/wangwang_list', to: 'callcenter#wangwang_list'
  get 'callcenter/remove_wangwang', to: 'callcenter#remove_wangwang'


  resources :colors do
    collection do
      get :autocomplete
    end
  end

  resources :categories do
    collection do
      get :deletes
      get :category_templates
      get :product_templates
      get :sku_templates
    end
  end
  resources :category_properties do
    collection do
      get :deletes
    end
  end


  get 'callcenter/contrastive_performance'
  get 'callcenter/inquired_and_created'
  get 'callcenter/created_and_paid'
  get 'callcenter/followed_paid'
  get 'callcenter/settings'
  get 'callcenter/adjust_filter'

  resources :sellers do
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
    resources :skus
    member do
      get :taobao_product
    end
    collection do
      get :fetch_products
      get :taobao_products
      get :pick_product
      get :abandon_product
      get :export_products
      post :update_on_sale
      get :taobao_skus
      get :change_taobao_skus
      post :tie_to_native_skus
      get :sync_taobao_products
      put :confirm_sync
      get :fetch_category_properties
      post :add_sku
      put :remove_sku
    end
  end

  get "/print_flash_settings/info_list.:format", to: "print_flash_settings#info_list"
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
      get :deletes
    end
    resources :print_flash_settings, only: [:show] do
      member do
        get :print_infos
        post :update_infos
      end
    end
  end

  resources :onsite_services do
    collection do
      get :onsite_service_area
      get :remove_onsite_service_area
      get :create_onsite_service_area
    end
  end

  match '/switch_account/:id', to: 'users#switch_account', as: :switch_account
  resources :users do
    collection do
      post :search
      get :roles
      put :create_role
      get :limits
      get :edit_with_role
      post :batch_update
      put :update_permissions
      post :destroy_role
      post :delete_users
      post :lock_users
      post :unlock_users
      post :users_muti
      post :delete
    end
  end

  resources :areas
  resources :trade_sources
  resources :accounts

  resources :account_setups do
    collection do
      get  :edit_preprocess_settings
      get  :edit_dispatch_settings
      get  :edit_deliver_settings
      put  :update_preprocess_settings
      put  :update_dispatch_settings
      put  :update_deliver_settings
    end
    member do
      post :data_fetch_start
      get  :data_fetch_check
      put  :data_fetch_finish
    end
  end
  resources :taobao_app_tokens, only: [:create]

  get "/sales/area_analysis", to: 'sales#area_analysis'
  get "/sales/time_analysis", to: 'sales#time_analysis'
  get "/sales/product_analysis", to: 'sales#product_analysis'
  get "/sales/price_analysis", to: 'sales#price_analysis'
  get "/sales/frequency_analysis", to: 'sales#frequency_analysis'
  get "/sales/univalent_analysis", to: 'sales#univalent_analysis'
  #get "/sales/customer_analysis", to: 'sales#customer_analysis'
  resources :sales

  resources :custom_trades do
    collection do
      get :change_taobao_products
    end
  end

  match '/alerts', to: 'trades#alerts'
  match '/my_alerts', to: 'trades#my_alerts'
  get "trades/new", to: "trades#new"
  get "trades/create", to: "trades#create"
  get "/trades/:id/sellers_info", to: "trades#sellers_info"
  get "/trades/:id/split_trade", to: "trades#split_trade"
  get "/trades/:id/print_deliver_bill", to: "trades#print_deliver_bill"
  get "/trades/batch_deliver", to: 'trades#batch_deliver'
  get "/trades/batch_check_goods", to: 'trades#batch_check_goods'
  get "/trades/batch_export", to: 'trades#batch_export'
  get "/deliver_bills/print_deliver_bill.:format", to: "deliver_bills#print_deliver_bill"
  get "/deliver_bills/:id/logistic_info", to: "deliver_bills#logistic_info"
  put "/deliver_bills/:id/split_invoice", to: "deliver_bills#split_invoice"
  get "/deliver_bills/deliver_list", to: "deliver_bills#deliver_list"
  get "/deliver_bills/logistic_waybill_list", to: "deliver_bills#logistic_waybill_list"
  get "/deliver_bills/verify_logistic_waybill", to: "deliver_bills#verify_logistic_waybill"

  get "/deliver_bills/batch-print-deliver", to: 'deliver_bills#batch_print_deliver'
  get "/deliver_bills/batch-print-logistic", to: 'deliver_bills#batch_print_logistic'
  get "/deliver_bills/setup_logistics", to: 'deliver_bills#setup_logistics'

  # get "/trades/deliver_list", to: "trades#deliver_list"
  # get "/deliver_bills/setup_logistics", to: 'deliver_bills#setup_logistics'

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
    resources :trade_searches
  end

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: "home#dashboard"

  match '/go/npsellers', :to => 'go#npsellers'
  match "/app", to: "home#index"
  match "*path", to: "home#index"

end
