# config/routes.rb
Rails.application.routes.draw do
  # Health check для балансировщиков и мониторинга
  get "/up", to: "health#show", as: :health

  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      # Authentication
      post "/auth/register", to: "auth#register", as: :auth_register
      post "/auth/login", to: "auth#login", as: :auth_login
      post "/auth/refresh", to: "auth#refresh", as: :auth_refresh
      delete "/auth/logout", to: "auth#logout", as: :auth_logout
      resources :tank_tech_specs, only: [:index]
      resources :comments, only: [:index]

      # Public Resources
      resources :games, only: %i[index show], param: :slug do
        scope module: :games do
          resources :articles, only: %i[index show], param: :slug
          resources :tank_tech_specs, only: %i[index show], param: :id
        end
      end

      resources :articles, only: %i[index show], param: :slug do
        member do
          get :related
        end
      end

      resources :tank_tech_specs, only: %i[index show], param: :id do
        collection do
          get :compare
        end
      end

      # Taxonomy
      resources :categories, only: %i[index show], param: :slug do
        resources :articles, only: [:index], module: :categories
      end

      # User Resources (JWT Protected)
      namespace :user, constraints: {format: :json} do
        resource :profile, only: %i[show update], controller: "profile"
        resources :bookmarks, only: %i[index create destroy]
        resources :ratings, only: %i[create update destroy]
      end

      resources :posts do
        resources :comments, only: [:create, :index]
      end

      # Admin (Role-based access)
      namespace :admin, module: :admin do
        resources :articles, except: %i[new edit] do
          member do
            post :publish
            post :unpublish
          end
        end
      end
    end
  end
end
