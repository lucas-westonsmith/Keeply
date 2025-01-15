class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  before_action :set_list, only: [:new, :create]
  before_action :authenticate_user!

  # Afficher tous les objets de l'utilisateur
  def index
    @items = current_user.items

    # Tri
    case params[:sort]
    when 'price_asc'
      @items = @items.order(price: :asc)
    when 'price_desc'
      @items = @items.order(price: :desc)
    end

    # Filtres
    @items = @items.where(category: params[:category]) if params[:category].present?
    @items = @items.where(condition: params[:condition]) if params[:condition].present?
    @items = @items.joins(:lists).where(lists: { id: params[:list_id] }) if params[:list_id].present?
  end


  # Afficher un objet spécifique
  def show
  end

  # Formulaire pour créer un objet
  def new
    @item = Item.new
  end

  # Créer un objet
  def create
    @item = current_user.items.build(item_params)

    if @item.save
      # Ajoutez les listes sélectionnées, tout en évitant les doublons
      if params[:item][:list_ids].present?
        unique_list_ids = params[:item][:list_ids].reject(&:blank?).uniq
        unique_list_ids.each do |list_id|
          ItemList.find_or_create_by(item_id: @item.id, list_id: list_id)
        end
      end
      redirect_to @item, notice: 'The item has been successfully added.'
    else
      flash.now[:alert] = "Unable to save the item. Please check the form."
      render :new
    end
  end


  # Formulaire pour modifier un objet
  def edit
    @list = @item.lists.first
  end

  # Mettre à jour un objet
  def update
    if @item.update(item_params)
      # Met à jour les associations avec les listes
      @item.lists = List.where(id: params[:item][:list_ids].reject(&:blank?)) if params[:item][:list_ids].present?
      redirect_to @item, notice: 'The item has been successfully updated.'
    else
      flash.now[:alert] = "Unable to update the item. Please check the form."
      render :edit
    end
  end

# Supprimer un objet
def destroy
  @item.item_lists.destroy_all # Supprime les associations dans item_lists
  @item.destroy # Supprime l'item après avoir supprimé les associations
  redirect_to items_path, notice: "Item was successfully deleted."
rescue StandardError => e
  redirect_to items_path, alert: "Failed to delete the item: #{e.message}"
end


  private

  def set_item
    @item = Item.find(params[:id])
  end

  def set_list
    @list = List.find_by(id: params[:list_id])
  end

  def item_params
    params.require(:item).permit(:title, :description, :price, :condition, :category, :purchase_date, :warranty_expiry_date, :photo, :invoice, list_ids: [])
  end
end
