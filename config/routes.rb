Zuuzlo::Application.routes.draw do
  
  devise_for :users
  
  root to: 'stores#index'

  get 'ui(/:action)', controller: 'ui'
  
  resources :users, only: [:show]

  
  resources :stores, except: [:destory] do
    member do 
      post 'save_store'
      post 'remove_store'
    end
  end

  resources :categories, only: [:show]
  resources :ctypes, only: [:show]

  resources :coupons do
    member do
      post 'toggle_favorite'
      get 'coupon_link'
    end

    collection do
      get 'search', to: 'coupons#search'
      get 'tab_all'
      get 'tab_coupon_codes'
      get 'tab_offers'
    end
  end

  namespace :admin do
    resources :stores, only: [:index]
    get 'get_ls_stores', to: 'stores#get_ls_stores'
    get 'get_pj_stores', to: 'stores#get_pj_stores'
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
