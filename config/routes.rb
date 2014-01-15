require 'sidekiq/web'

MagicOrders::Application.routes.draw do

  resources :jushita_data do
    collection do
      put :lock
      put :enable
    end
  end

  resources :trade_types

  resource :page do
    collection do
      get :default
      get :overview
      get :reload_trades_percent_analysis
      get :reload_customers_percent_analysis
    end
  end

  resources :third_parties do
    post :reset_token, on: :collection
  end


  resources :customers ,:only => [:index,:show] do

    collection do
      get :potential
      get :paid
      get :around
      get :send_messages
      get :get_recipients
      post :invoice_messages
    end
  end

  resources :warehouses   ,:only => [:index] do
    post :batch_update_safety_stock,:on => :collection
    resources :stock_bills
    resources :refund_products do
      collection do
        post :locking
        post :sync
        post :check
        post :rollback
        post :enable
        get  :refund_fetch
        put  :refund_save
      end
    end

    resources :stock_in_bills do
      member do
        get :fetch_category_properties
      end
      collection do
        post :sync
        post :check
        post :rollback
        post :lock
        post :unlock
        put :confirm_sync
        put :confirm_stock
        put :confirm_cancle
        put :refuse_cancle
      end
    end

    resources :stock_out_bills do
      collection do
        post :sync
        post :check
        post :rollback
        post :lock
        post :unlock
        put :confirm_sync
        put :confirm_stock
        put :confirm_cancle
        put :refuse_cancle
      end
    end

    resources :stocks     , only: [:index,:show] do
      collection do
        get :edit_depot
        post :batch_update_safety_stock
        post :batch_update_actual_stock
        put :inventory
      end
      put :update_depot   ,:on => :member
    end
    resources :stock_csv_files
    resources :refund_products
  end

  resources :stocks     , only: [:index,:show] do
    put :update_depot   ,:on => :member
    collection do
      post :batch_update_safety_stock
      post :batch_update_actual_stock
      get :edit_depot
    end
  end

  match "/stock_out_bills/get_bills",to: "stock_out_bills#get_bills"
  match "/stock_out_bills/get_products",to: "stock_out_bills#get_products"
  match "/stocks/safe_stock", to: 'stocks#safe_stock'
  post "/stocks/edit_safe_stock", to: 'stocks#edit_safe_stock'
  post "/stock_bills/update_status", to: 'stock_bills#update_status'
  match "/stocks/change_product_type", to: 'stocks#change_product_type'
  get "notify/sms"
  get "notify/email"

  wash_out :trade_api
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

  resources :deliver_templates do
    collection do
      post :change_default_template
    end
  end

  resources :reconcile_statements, only: [:index, :show] do
    member do
      put :audit
      put :update_processed
      get :seller_show
      get :distributor_show
    end
    collection do
      get :exports
      get :seller_exports
      get :distributor_exports
      get :seller_index
      get :distributor_index
      get :product_detail_exports
      put :audits
      put :process_all
      put :generate_new
    end
    resources :reconcile_statement_details, only: [:show] do
      member do
        get :export_detail
        get :change_detail
      end
    end
    resources :reconcile_seller_details, only: [:show] do
      member do
        get :export_detail
        get :change_detail
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
  match '/auth/jidong/callback', to: 'jingdong_app_tokens#index'
  match '/auth/yihaodian/callback', to: 'yihaodian_app_tokens#index'

  #get "callbacks/jingdong"
  get '/autologin', to: 'users#autologin'
  get '/sale_areas',  to: "users#sale_areas"
  devise_for :users, :path => '', :path_names => {:sign_in => 'login'},
    controllers: { sessions: "sessions" , registrations: "registrations"}

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
      get :same_level_categories
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
      post :import_csv
      post :confirm_import_csv
      post :active_seller
      post :shutdown_seller
      post :user_list
      get :seller_user
      get :seller_user_list
      get :remove_seller_user
      get :seller_area
      get :create_seller_area
      get :remove_seller_area
      get :latest
      get :closed
      get :export
      get :import
      get :area_sellers
    end
  end

  resources :jingdong_products do
    collection do
      get :sync
      put :syncing
      get :jingdong_skus
      get :change_jingdong_skus
      post :tie_to_native_skus
    end
  end

  resources :yihaodian_products do
    collection do
      get :sync
      put :syncing
      get :yihaodian_skus
      get :change_yihaodian_skus
      post :tie_to_native_skus
    end
  end

  resources :products do
    resources :skus
    member do
      get :taobao_product
    end
    collection do
      post :import_csv
      post :confirm_import_csv
      get :fetch_products
      get :taobao_products
      get :pick_product
      get :abandon_product
      get :export_products
      get :import
      post :update_on_sale
      get :taobao_skus
      get :change_taobao_skus
      get :search_native_skus
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
      get :all_logistics
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
        put :update_xml_hash
      end
    end
    resources :logistic_areas do
      collection do
        post :update_post_info
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
      post :batch_update
      put :update_permissions
      post :destroy_role
      post :delete_users
      post :lock_users
      post :unlock_users
      post :users_muti
      post :delete
      post :update_visible_columns
    end
    get :edit_with_role , :on => :member
  end

  resources :areas do
    collection do
      get :sellers
      get :export
      get :import
      post :import_csv
      post :confirm_import_csv
    end
  end

  resources :trade_sources
  resources :accounts

  resources :account_setups do
    collection do
      AutoSettingsHelper::AutoBlocks.each do |block|
        get "edit_#{block}_settings".to_sym
        put "update_#{block}_settings".to_sym
      end
    end
    member do
      post :data_fetch_start
      get  :data_fetch_check
      put  :data_fetch_finish
    end
  end
  resources :taobao_app_tokens, only: [:create]

  resources :sales do
    collection do
      get :add_node
      get :summary
      get :area_analysis
      get :time_analysis
      get :product_analysis
      get :price_analysis
      get :frequency_analysis
      get :univalent_analysis
    end
  end

  resources :custom_trades do
    collection do
      get :change_products
      get :calculate_price
      get :calculate_payment
    end
  end

  match '/my_alerts', to: 'trades#my_alerts'
  get "trades/new", to: "trades#new"
  get "/trades/create", to: "trades#create"
  get "/trades/show_percent", to: "trades#show_percent"
  get "/trades/assign_percent", to: "trades#assign_percent"
  get "/trades/invoice_setting", to: "trades#invoice_setting"
  post "/trades/change_invoice_setting", to: "trades#change_invoice_setting"
  get "/trades/:id/sellers_info", to: "trades#sellers_info"
  get "/trades/:id/split_trade", to: "trades#split_trade"
  get "/trades/:id/print_deliver_bill", to: "trades#print_deliver_bill"
  get "/trades/batch_deliver", to: 'trades#batch_deliver'
  get "/trades/batch_check_goods", to: 'trades#batch_check_goods'
  get "/trades/batch_export", to: 'trades#batch_export'
  get "/trades/batch_add_gift", to: "trades#batch_add_gift"
  get "/trades/verify_add_gift", to: "trades#verify_add_gift"
  get "/trades/deliver_list", to: "trades#deliver_list"
  get "/trades/lock_trade", to: "trades#lock_trade"
  get "/trades/activate_trade", to: "trades#activate_trade"
  post "/trades/merge", to: "trades#merge"
  get "/trades/split/:id", to: "trades#split"
  get "/deliver_bills/print_deliver_bill.:format", to: "deliver_bills#print_deliver_bill"
  get "/deliver_bills/:id/logistic_info", to: "deliver_bills#logistic_info"
  put "/deliver_bills/:id/split_invoice", to: "deliver_bills#split_invoice"
  get "/deliver_bills/deliver_list", to: "deliver_bills#deliver_list"
  get "/deliver_bills/logistic_waybill_list", to: "deliver_bills#logistic_waybill_list"
  get "/deliver_bills/verify_logistic_waybill", to: "deliver_bills#verify_logistic_waybill"

  get "/deliver_bills/batch-print-deliver", to: 'deliver_bills#batch_print_deliver'
  get "/deliver_bills/batch-print-logistic", to: 'deliver_bills#batch_print_logistic'
  get "/deliver_bills/setup_logistics", to: 'deliver_bills#setup_logistics'

  get "/logistic_rates", to: 'logistic_rates#index'
  get "/change_stock_product", to: 'stock_products#change_stock_product'

  scope 'api' do
    get "areas", to: "areas#index"

    resources :trades do
      member do
        get :seller_for_area
        get :estimate_dispatch
        get :split_trade
        get :recover
      end

      collection do
        get :notifer
        get :export
        get :sort_product_search
        get :match_icp_bills
      end
    end

    resources :products
    resources :deliver_bills do
      collection do
        get :print_process_sheets
      end
    end
    resources :trade_searches
  end

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: "pages#index"
  # API
  require 'api'
  mount MagicOrder::API => '/api'

  match '/go/npsellers', :to => 'go#npsellers'
  match "/app", to: "home#index"
  match "*path", to: "home#index"

end
