MagicOrders::Application.routes.draw do
  resources :areas do
   collection do
    get :export
    get :autocomplete
    match :area_search
    match :remap_sellers
  end
end
