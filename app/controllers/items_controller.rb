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
    when 'newest_first'
      @items = @items.order(created_at: :desc)
    when 'oldest_first'
      @items = @items.order(created_at: :asc)
    else
      # 🌟 Appliquer le tri par défaut SEULEMENT si aucun tri n'est défini
      @items = @items.order(created_at: :desc) if params[:sort].blank?
    end

    # Filtres
    @items = @items.where(category: params[:category]) if params[:category].present?
    @items = @items.where(condition: params[:condition]) if params[:condition].present?
    @items = @items.where(issuer: params[:issuer]) if params[:issuer].present?
    @items = @items.joins(:lists).where(lists: { id: params[:list_id] }) if params[:list_id].present?
  end

  # Afficher un objet spécifique
  def show; end

  # Formulaire pour créer un objet
  def new
    @item = Item.new
    @super_list_id = params[:super_list_id] || current_user.super_lists.first&.id
    @filtered_lists = current_user.lists.where(super_list_id: @super_list_id)
    @categories = @item.possible_categories # 🔥 Assure que les catégories sont définies

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
    @categories = @item.possible_categories

    # ✅ Ajoute la catégorie actuelle si elle n’est pas déjà présente
    unless @categories[:specific].include?(@item.category) || @categories[:common].include?(@item.category)
      @categories[:specific] << @item.category if @item.category.present?
    end
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

  def alerts
    @items = current_user.items

    # ✅ Appliquer les filtres utilisateur pour les garanties uniquement
    warranty_items = @items.dup
    if params[:filter_type] == "warranty"
      warranty_items = warranty_items.where(category: params[:warranty_category]) if params[:warranty_category].present?
      warranty_items = warranty_items.where(condition: params[:warranty_condition]) if params[:warranty_condition].present?
      warranty_items = warranty_items.joins(:lists).where(lists: { id: params[:warranty_list_id] }) if params[:warranty_list_id].present?
    end

    # 📌 Gérer le filtre Expiration (ne s’applique qu’aux warranties)
    if params[:expiration] == "expired"
      @expiring_warranties = warranty_items.where('warranty_expiry_date < ?', Date.today)
                                           .order(warranty_expiry_date: :asc)
    else
      expiration_period = case params[:expiration]
                          when '1_month' then 1.month.from_now
                          when '6_months' then 6.months.from_now
                          when '1_year' then 1.year.from_now
                          else 3.months.from_now
                          end

      @expiring_warranties = warranty_items.where('warranty_expiry_date BETWEEN ? AND ?', Date.today, expiration_period)
                                           .order(warranty_expiry_date: :asc)
    end

    # ✅ Appliquer les filtres utilisateur pour l'obsolescence uniquement
    obsolescence_items = @items.dup
    if params[:filter_type] == "obsolescence"
      obsolescence_items = obsolescence_items.where(category: params[:obsolescence_category]) if params[:obsolescence_category].present?
      obsolescence_items = obsolescence_items.where(condition: params[:obsolescence_condition]) if params[:obsolescence_condition].present?
      obsolescence_items = obsolescence_items.joins(:lists).where(lists: { id: params[:obsolescence_list_id] }) if params[:obsolescence_list_id].present?
    end

    # 📌 Récupérer les items potentiellement obsolètes
    all_obsolete_items = Item.find_potentially_obsolete_items(obsolescence_items)

    # ✅ Vérifier que chaque item a `years_old` et `lifespan`
    all_obsolete_items.select! { |entry| entry[:years_old] && entry[:lifespan] }

    # 📌 Séparer les objets complètement obsolètes et ceux qui approchent de l'obsolescence
    @completely_obsolete = all_obsolete_items.select { |entry| entry[:years_old] >= entry[:lifespan] }
    @potentially_obsolete = all_obsolete_items.reject { |entry| entry[:years_old] >= entry[:lifespan] }

    # 📌 Appliquer le filtre d'obsolescence correctement
    case params[:obsolescence]
    when "obsolete"
      @filtered_obsolete = @completely_obsolete
    when "1_month"
      @filtered_obsolete = @potentially_obsolete.select { |entry| entry[:years_old] >= entry[:lifespan] - (1.0 / 12) }
    when "3_months"
      @filtered_obsolete = @potentially_obsolete.select { |entry| entry[:years_old] >= entry[:lifespan] - 0.25 }
    when "6_months"
      @filtered_obsolete = @potentially_obsolete.select { |entry| entry[:years_old] >= entry[:lifespan] - 0.5 }
    when "1_year"
      @filtered_obsolete = @potentially_obsolete.select { |entry| entry[:years_old] >= entry[:lifespan] - 1 }
    else
      @filtered_obsolete = @potentially_obsolete
    end
  end

  def update_categories
    list_ids = params[:lists].to_s.split(",").map(&:to_i)
    puts "🧐 IDs des listes reçues : #{list_ids.inspect}"

    lists = List.where(id: list_ids)
    puts "🔍 Listes trouvées : #{lists.pluck(:title).inspect}"

    if lists.empty?
      render json: { error: "No lists found" }, status: :unprocessable_entity
    else
      categories = Item.fetch_categories_for_lists(lists.pluck(:title))
      puts "📌 Catégories retournées : #{categories.inspect}"

      # ✅ Empêcher l'ajout d'une catégorie vide (" ")
      categories[:specific].reject!(&:blank?)
      categories[:common].reject!(&:blank?)

      # ✅ Vérifier si on est en mode édition et inclure la catégorie actuelle si nécessaire
      if params[:item_id].present?
        item = Item.find_by(id: params[:item_id])
        if item&.category.present? && !categories[:specific].include?(item.category) && !categories[:common].include?(item.category)
          categories[:specific] << item.category
        end
      end

      render partial: "items/categories", locals: { categories: categories }
    end
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
