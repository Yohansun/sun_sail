require 'sidekiq/web'

MagicOrders::Application.routes.draw do

  get "callbacks/jingdong"
  get '/autologin', to: 'users#autologin'
  devise_for :users, :path => '', :path_names => {:sign_in => 'login'}

  match "sellers", to: 'home#index'

  resources :sellers do
    resources :stocks
    resources :stock_products do
      resources :stock_history
    end
  end

  resources :products do
    get :made_sold_out
    get :made_on_sale
  end

  scope 'api' do
    resources :trades do
      collection do
        get :notifer
      end
    end

    resources :sellers do
      member do
        resources :stocks
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