require 'sidekiq/web'

MagicOrders::Application.routes.draw do

  mount Sidekiq::Web => '/sidekiq'

  devise_for :users

  scope 'api' do
    resources :trades
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

  root to: "home#index"
  match "*path", to: "home#index"

end