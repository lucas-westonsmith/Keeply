Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home" # Page d'accueil

  # Ressources pour gérer les listes
  resources :lists, shallow: true do
    resources :items, only: [:new, :create, :index, :edit, :update]
  end

  # Définition explicite de la route pour supprimer un item d'une liste
  delete '/lists/:id/remove_item/:item_id', to: 'lists#remove_item', as: :remove_item_from_list

  # Définir explicitement les actions "new" en dehors des conflits
  get '/items/new', to: 'items#new', as: :new_item

  # Route pour afficher tous les objets indépendamment des listes
  resources :items, only: [:index, :show, :edit, :update, :destroy]

  # Gestion des utilisateurs dans les listes (inviter et retirer)
  resources :list_users, only: [:create, :destroy]

  # Vérification de l'état de santé de l'application
  get "up" => "rails/health#show", as: :rails_health_check
  get 'profile', to: 'users#show', as: :profile
end
