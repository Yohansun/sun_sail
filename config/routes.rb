MagicOrders::Application.routes.draw do
  get "home/index"

  devise_for :users

  resources :areas do
    collection do
      get :export
      get :autocomplete
      match :area_search
      match :remap_sellers
    end
  end

  root to: "home#index"
end