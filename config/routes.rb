Rails.application.routes.draw do
  devise_for :users

  # Page d'accueil
  root to: "pages#home"

  # Page de profil utilisateur
  get '/profile', to: 'pages#profile', as: :profile

  # Ressources pour gérer les sur-listes avec des URL lisibles
  get '/menu', to: 'super_lists#index', as: :menu
  get '/menu/home', to: 'super_lists#show', defaults: { title: 'Home' }, as: :menu_home
  get '/menu/everyday-life', to: 'super_lists#show', defaults: { title: 'Everyday life' }, as: :menu_everyday_life
  get '/menu/administrative-papers', to: 'super_lists#show', defaults: { title: 'Administrative papers' }, as: :menu_administrative_papers

  # Ressources pour gérer les listes
  resources :lists, shallow: true do
    resources :items, only: [:new, :create, :index, :edit, :update]
    resources :list_users, only: [:create, :destroy]
    post 'leave', to: 'list_users#leave', as: :leave_list
    post 'add_existing_item/:item_id', to: 'lists#add_existing_item', as: :add_existing_item_to_list
  end

  # Ressources pour les items (indépendamment des listes)
  resources :items do
    collection do
      get :update_lists # Route pour la mise à jour des listes dynamiques
    end
  end

  # Définition explicite de la route pour supprimer un item d'une liste
  delete '/lists/:id/remove_item/:item_id', to: 'lists#remove_item', as: :remove_item_from_list

  # Vérification de l'état de santé de l'application
  get "up" => "rails/health#show", as: :rails_health_check
end
