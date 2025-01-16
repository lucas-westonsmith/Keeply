class ListsController < ApplicationController
  before_action :set_list, only: [:show, :edit, :update, :destroy, :remove_item]
  before_action :authenticate_user!

  # Afficher toutes les listes de l'utilisateur
  def index
    @lists = List
               .left_outer_joins(:list_users)
               .where("lists.user_id = :user_id OR list_users.user_id = :user_id", user_id: current_user.id)
               .distinct
  end

  # Afficher une liste spécifique
  def show
    @list = List.includes(:users, :list_users).find(params[:id])
    @items_in_list = @list.items
  end

  # Formulaire pour créer une nouvelle liste
  def new
    @list = current_user.lists.build
  end

  # Créer une nouvelle liste
  def create
    @list = current_user.lists.build(list_params)

    # Si une miniature est sélectionnée, on l'attache comme photo
    if params[:default_photo].present? && !list_params[:photo].present?
      @list.photo.attach(io: File.open(Rails.root.join("app", "assets", "images", params[:default_photo])), filename: params[:default_photo])
    end

    if @list.save
      redirect_to @list, notice: 'The list has been successfully created.'
    else
      render :new
    end
  end


  # Formulaire pour modifier une liste
  def edit; end

  # Mettre à jour une liste
  def update
    if @list.update(list_params)
      redirect_to @list, notice: 'The list has been successfully updated.'
    else
      render :edit
    end
  end

  # Supprimer une liste
  def destroy
    if @list.user == current_user
      @list.destroy
      redirect_to lists_path, notice: 'The list has been deleted.'
    else
      redirect_to lists_path, alert: "You can't delete a list you don't own."
    end
  end

  # Supprimer un item d'une liste
  def remove_item
    item = @list.items.find(params[:item_id])
    if @list.items.delete(item)
      redirect_to @list, notice: 'Item successfully removed from the list.'
    else
      redirect_to @list, alert: 'Failed to remove the item from the list.'
    end
  end

  private

  def set_list
    @list = List.find(params[:id])
  end

  def list_params
    params.require(:list).permit(:title, :description, :photo)
  end
end
