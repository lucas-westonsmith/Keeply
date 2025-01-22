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
  def show; end

  # Formulaire pour créer un objet
  def new
    @item = Item.new
    @super_list_id = params[:super_list_id] || current_user.super_lists.first&.id
    @filtered_lists = current_user.lists.where(super_list_id: @super_list_id)

    respond_to do |format|
      format.html
      format.html { render partial: "items/lists", locals: { filtered_lists: @filtered_lists, form: nil, item_lists: [] } }
    end
  end

  # Mise à jour des listes dynamiques
  def update_lists
    @super_list_id = params[:super_list_id]
    @filtered_lists = current_user.lists.where(super_list_id: @super_list_id)
    @item_lists = Item.find_by(id: params[:item_id])&.lists&.pluck(:id) || []

    render partial: "items/lists", locals: { filtered_lists: @filtered_lists, item_lists: @item_lists }
  end

  # Créer un objet
  def create
    @item = current_user.items.build(item_params)

    if @item.save
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
    @super_list_id = @item.lists.first&.super_list_id || current_user.super_lists.first&.id
    @filtered_lists = current_user.lists.where(super_list_id: @super_list_id)
    @item_lists = @item.lists.pluck(:id)
  end

  # Mettre à jour un objet
  def update
    if @item.update(item_params)
      @item.lists = List.where(id: params[:item][:list_ids].reject(&:blank?)) if params[:item][:list_ids].present?
      redirect_to @item, notice: 'The item has been successfully updated.'
    else
      flash.now[:alert] = "Unable to update the item. Please check the form."
      render :edit
    end
  end

  # Supprimer un objet
  def destroy
    @item.item_lists.destroy_all
    @item.destroy
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
    params.require(:item).permit(:title, :description, :price, :condition, :category, :issuer, :purchase_date, :warranty_expiry_date, :photo, :invoice, list_ids: [])
  end
end
