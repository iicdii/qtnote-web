Rails.application.routes.draw do
  devise_for :users, skip: [:session, :password, :registration, :confirmation], controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  
  root 'home#index'
  scope "(:locale)", locale: /ko|en/ do
    devise_for :users, skip: :omniauth_callbacks, controllers: {sessions: "users/sessions", registrations: "users/registrations"}
    get 'omniauth/:provider' => 'omniauth#localized', as: :localized_omniauth
    
    get '/' => 'home#index'
    get '/profile' => 'home#profile'
    post '/write' => 'home#write'
    post '/modify' => 'home#modify'
    get '/users/:id' => 'users/profile#index', as: 'user'
    get '/posts/:id' => 'posts#index', as: 'post'
    post '/posts/fetch' => 'posts#fetch', as: 'fetch_posts'
    post '/posts/:id/like' => 'posts#like', as: 'like_post'
    post '/posts/:id/dislike' => 'posts#dislike', as: 'dislike_post'
    get '/messages' => 'messages#index', as: 'messages'
    post '/messages/read' => 'messages#read', as: 'read_message'
  end
  
  get '/:locale' => 'home#index'

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
