class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  before_action :set_list, only: [:new, :create]  # Ajoute un before_action pour récupérer la liste
  before_action :authenticate_user!

  # Afficher tous les objets de l'utilisateur
  def index
    @items = current_user.items
  end

  # Afficher un objet spécifique
  def show
  end

  # Formulaire pour créer un objet
  def new
    @item = @list ? @list.items.build : Item.new
  end

  # Créer un objet
  def create
    @item = current_user.items.build(item_params) # Associer l'utilisateur à l'item
    if @item.save
      # Si une ou plusieurs listes sont sélectionnées, les associer via item_lists
      if params[:item][:list_ids].present?
        @item.lists << List.where(id: params[:item][:list_ids])
      end
      redirect_to @item, notice: 'The item has been successfully added.'
    else
      flash.now[:alert] = "Unable to save the item. Please check the form."
      render :new
    end
  end



  # Formulaire pour modifier un objet
  def edit
    @list = @item.lists.first # Si l'item appartient à une ou plusieurs listes, prendre la première
  end

  # Mettre à jour un objet
  def update
    if @item.update(item_params)
      # Met à jour les associations avec les listes
      @item.lists = List.where(id: params[:item][:list_ids]) if params[:item][:list_ids].present?
      redirect_to @item, notice: 'The item has been successfully updated.'
    else
      flash.now[:alert] = "Unable to update the item. Please check the form."
      render :edit
    end
  end


  # Supprimer un objet
  def destroy
    @item.destroy
    redirect_to items_path, notice: "Item was successfully deleted."
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def set_list
    @list = List.find(params[:list_id]) if params[:list_id]  # Si un paramètre list_id est présent, on récupère la liste
  end

  def item_params
    params.require(:item).permit(:title, :description, :price, :condition, :category, :purchase_date, :warranty_expiry_date, :photo, :invoice, list_ids: [])
  end
end
