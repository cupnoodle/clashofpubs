Rails.application.routes.draw do

  root 'static#index'
  get 'index' => 'static#index'
  get 'about' => 'static#about'
  get 'teams' => 'static#teams'
  
  get 'schedule' => 'matchings#index'
  get 'schedule/edit' => 'matchings#schedule'
  post 'schedule/submit' => 'matchings#submit_datetime'

  get 'register' => 'players#new'
  post 'player/create' => 'players#create'

  get 'player/full' => 'players#full'
  
  get 'login' => 'players#login'
  post 'login' => 'players#attempt_login'
  get 'logout' => 'players#logout'

  get 'admin' => 'admin#index'
  get 'admin/login' => 'admin#login'
  post 'admin/login' => 'admin#attempt_login'
  get 'admin/logout' => 'admin#logout'
  get 'admin/schedule' => 'admin#schedule'
  post 'admin/schedule' => 'admin#update_match'
  get 'admin/winner' => 'admin#winner'
  post 'admin/winner' => 'admin#update_winner'

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
