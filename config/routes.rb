Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  get '/profile', to: 'pages#profile', as: :profile

  get '/menu', to: 'super_lists#index', as: :menu
  get '/menu/home-items', to: 'super_lists#show', defaults: { title: 'Home items' }, as: :menu_home_items
  get '/menu/everyday-life', to: 'super_lists#show', defaults: { title: 'Everyday life' }, as: :menu_everyday_life
  get '/menu/administrative-papers', to: 'super_lists#show', defaults: { title: 'Administrative papers' }, as: :menu_administrative_papers

  resources :lists, shallow: true do
    resources :items, only: [:new, :create, :index, :edit, :update]
    resources :list_users, only: [:create, :destroy]
    post 'leave', to: 'list_users#leave', as: :leave_list
    post 'add_existing_item/:item_id', to: 'lists#add_existing_item', as: :add_existing_item_to_list
  end

  resources :items do
    collection do
      get :update_lists
      get :alerts  # ✅ Ajoute la page d'alertes
      get :update_categories  # ✅ Ajout de la mise à jour AJAX des catégories
    end
  end

  delete '/lists/:id/remove_item/:item_id', to: 'lists#remove_item', as: :remove_item_from_list

  get "up" => "rails/health#show", as: :rails_health_check
end
