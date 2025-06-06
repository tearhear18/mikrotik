Rails.application.routes.draw do
  get 'agents/index'
  devise_for :users
  root to: 'home#index'

  resources :routers do
    collection do
      get :add_router
    end
  end

  resources :agents do
    get :sales_collected
    get :sales_calculate
    get :code_generator
    resources :agent_documents, only: [:show, :destroy]
    
    collection do 
      get :update_sales
    end
  end

  namespace :api do
    get 'search_vouchers/:code', to: 'vouchers#index'
    get 'voucher_info/:code', to: 'vouchers#show'
    post 'add_time', to: 'vouchers#add_time'
    get 'delete/:code', to: 'vouchers#delete'
    # resources :vouchers do

      # collections do

    #   # end
    # end
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
