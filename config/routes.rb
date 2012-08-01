require 'sidekiq/web'

MagicOrders::Application.routes.draw do

  get 'autologin', to: 'users#autologin'
  devise_for :users

  scope 'api' do
    resources :trades do
      collection do
        get :notifer
      end
    end

    resources :sellers
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

  root to: "home#index"
  match "*path", to: "home#index"

end