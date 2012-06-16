MagicOrders::Application.routes.draw do
  mount MagicContent::Engine => '/admin/content', :as => 'magic_content'

  devise_for :admins, :controllers => { :sessions => 'magic_admin/sessions' }

  mount MagicAdmin::Engine => '/admin', :as => 'magic_admin'

  match "/admin/content/seller_posts" => "areas#index"

  #TODO 释放areas其他关联
   resources :areas do
  #     resources :areas_sellers
       collection do
  #       get :shipping_fee
        get :export
        get :autocomplete
        match :area_search
        match :remap_sellers
       end
  #     member do
  #       get :edit_shipping_fee
  #       put :update_shipping_fee
  #     end
  end
end
