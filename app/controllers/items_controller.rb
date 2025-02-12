class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy, :sell, :unsell, :buy]
  before_action :set_list, only: [:new, :create]
  before_action :authenticate_user!

  # Afficher tous les objets de l'utilisateur
  def index
    # Items que l'utilisateur possède (où il est buyer)
    owned_items = Item.where("buyer_id = ? OR (buyer_id IS NULL AND user_id = ?)", current_user.id, current_user.id)

    # Items des listes où il a été invité
    invited_list_ids = current_user.list_users.pluck(:list_id) # Récupère les listes où l'utilisateur est invité
    shared_items = Item.joins(:lists).where(lists: { id: invited_list_ids }).distinct

    # Fusion des résultats et suppression des doublons
    @items = (owned_items + shared_items).uniq

    # Debugging logs
    puts "👤 Utilisateur: #{current_user.email} (ID: #{current_user.id})"
    puts "🔍 Lists invitées: #{invited_list_ids.inspect}"
    puts "📦 Items possédés: #{owned_items.pluck(:id, :title)}"
    puts "📦 Items partagés: #{shared_items.pluck(:id, :title)}"
    puts "✅ Tous les items affichés: #{@items.pluck(:id, :title)}"

    # Appliquer les filtres et tris
    case params[:sort]
    when 'price_asc'
      @items = @items.sort_by(&:price)
    when 'price_desc'
      @items = @items.sort_by(&:price).reverse
    when 'newest_first'
      @items = @items.sort_by(&:created_at).reverse
    when 'oldest_first'
      @items = @items.sort_by(&:created_at)
    end

    # Filtres supplémentaires
    @items = @items.select { |item| item.category == params[:category] } if params[:category].present?
    @items = @items.select { |item| item.condition == params[:condition] } if params[:condition].present?
    @items = @items.select { |item| item.issuer == params[:issuer] } if params[:issuer].present?
    @items = @items.select { |item| item.lists.exists?(id: params[:list_id]) } if params[:list_id].present?
  end

  # Afficher un objet spécifique
  def show
    return if @item.for_sale? # ✅ Accessible si l'objet est en vente
    return if @item.buyer == current_user # ✅ Accessible au buyer actuel

    # 🔥 Récupère TOUTES les listes accessibles par l'utilisateur (celles créées + celles où il est invité)
    user_lists = current_user.lists.pluck(:id) + current_user.list_users.pluck(:list_id)
    item_lists = @item.lists.pluck(:id)

    puts "🔍 Debug: User Lists (owned + invited) -> #{user_lists.inspect}"
    puts "🔍 Debug: Item Lists -> #{item_lists.inspect}"
    puts "🔍 Debug: Intersection -> #{(user_lists & item_lists).inspect}"

    if (user_lists & item_lists).any?
      puts "✅ Access granted!"
      return
    else
      puts "❌ Access denied!"
    end

    redirect_to items_path, alert: "You do not have access to this item."
  end

  def extract_invoice_data
    return render json: { error: "No file uploaded" }, status: :unprocessable_entity unless params[:invoice]

    file = params[:invoice]
    tempfile = file.tempfile.path

    # 📂 Convertir le PDF en image si nécessaire
    if file.content_type == "application/pdf"
      image_path = "#{tempfile}.png"
      system("magick convert -density 300 #{tempfile}[0] -quality 100 #{image_path}")

      return render json: { error: "PDF conversion failed" }, status: :unprocessable_entity unless File.exist?(image_path)

      tempfile = image_path
    end

    # 🔍 Extraction OCR
    extracted_text = RTesseract.new(tempfile).to_s
    puts "🔎 OCR Extracted Text (Lignes séparées) :"
    extracted_text.each_line { |line| puts "👉 #{line.strip}" }

    # 💰 **EXTRACTION DU PRIX TOTAL (Total TTC en priorité)**
    total_regex = /
      (?:Total\s*(?:\(TTC\)|amount|due|Grand\s*Total|including\s*tax|Final\s*Price|Net\s*à\s*payer))
      \s*[:]?[\s\n]*
      (€|EUR|\$|USD|£|GBP|CHF|JPY|CAD|AUD)?
      \s*
      ([\d,.]+)
    /ix

    price_match = extracted_text.scan(total_regex)
    best_price = nil

    if price_match.any?
      best_price_data = price_match.last
      price_currency = best_price_data[0] || "€"
      price_value = best_price_data[1]

      price_value = price_value.gsub(/(?<=\d)[.,](?=\d{3}\b)/, "")
      price_value = price_value.gsub(",", ".") if price_value.count(",") == 1

      numeric_price = price_value.to_f
      best_price = "#{numeric_price.round(2)} #{price_currency}"
      puts "✅ Correct Price Extraction: #{best_price}"
    else
      puts "❌ AUCUN PRIX TROUVÉ VIA TOTAL TTC, ON DÉBUGUE :"
      total_lines = extracted_text.lines.select { |line| line.match?(/Total/i) }
      puts "🔎 LIGNES CONTENANT 'TOTAL' :"
      total_lines.each { |line| puts "👉 #{line.strip}" }

      price_matches = extracted_text.scan(/(€|EUR|\$|USD|£|GBP|CHF|JPY|CAD|AUD)?\s*([\d,.]+)/i)
      if price_matches.any?
        prices = price_matches.map do |match|
          currency = match[0] || "€"
          amount = match[1].gsub(/(?<=\d)[.,](?=\d{3}\b)/, "").gsub(",", ".").to_f
          [amount, currency]
        end

        puts "🔍 Tous les prix trouvés (y compris sans devise) : #{prices.inspect}"
        filtered_prices = prices.select { |amount, _| amount > 5 && amount < 10000 } # ✅ Exclusion des valeurs absurdes (évite 2025.0 €)
        if filtered_prices.any?
          best_price_value = filtered_prices.max_by { |amount, _| amount }
          best_price = "#{best_price_value[0].round(2)} #{best_price_value[1]}"
        end
        puts "🔎 Fallback Price Extraction: #{best_price}"
      else
        best_price = nil
      end
    end

    # 🏢 **Détection de l'Issuer (Ajout de `Émetteur : ...` en plus des autres formats)**
    issuer_regex = /(?:Company Name|Issued by|Fournisseur|Vendeur|Seller Details|Émetteur)\s*[:]?[\s\n]*(.+)/i
    issuer = extracted_text.match(issuer_regex)&.captures&.first&.strip if extracted_text.match(issuer_regex)

    puts "✅ Issuer Extraction: #{issuer}" if issuer

    # 📄 **Titre de l'Invoice**
    invoice_number_regex = /(?:Invoice Number|Facture|Commande|n°)\s*[:#]?\s*(\S+)/i
    invoice_number = extracted_text.match(invoice_number_regex)&.captures&.first

    title = if invoice_number && issuer
      "Invoice ##{invoice_number} - #{issuer}"
    elsif invoice_number
      "Invoice ##{invoice_number}"
    elsif issuer
      "Invoice - #{issuer}"
    else
      nil
    end

    # 📆 **Détection des Dates (Achat & Expiration garantie)**
    purchase_date_regex = /(?:Purchase Date|Date d'achat|Payment Date|Date)\s*[:]?[\s]?(\d{1,2}\s+\w+\s+\d{4}|\d{1,2}[-\/.]\d{1,2}[-\/.]\d{2,4}|\w+\s+\d{1,2},\s+\d{4})/i
    warranty_expiry_regex = /(?:Warranty Expiry Date|Date d'expiration de garantie|Valid until)\s*[:]?[\s]?(\d{1,2}\s+\w+\s+\d{4}|\d{1,2}[-\/.]\d{1,2}[-\/.]\d{2,4}|\w+\s+\d{1,2},\s+\d{4})/i

    purchase_date = extracted_text.match(purchase_date_regex)&.captures&.first
    warranty_expiry_date = extracted_text.match(warranty_expiry_regex)&.captures&.first

    def convert_date(date_string)
      return nil unless date_string
      begin
        Date.strptime(date_string, "%d/%m/%Y").strftime("%Y-%m-%d")
      rescue ArgumentError
        begin
          Date.strptime(date_string, "%m-%d-%Y").strftime("%Y-%m-%d")
        rescue ArgumentError
          begin
            Date.strptime(date_string, "%d %B %Y").strftime("%Y-%m-%d")
          rescue ArgumentError
            begin
              Date.strptime(date_string, "%B %d, %Y").strftime("%Y-%m-%d")
            rescue ArgumentError
              nil
            end
          end
        end
      end
    end

    purchase_date = convert_date(purchase_date)
    warranty_expiry_date = convert_date(warranty_expiry_date)

    render json: {
      price: best_price,
      issuer: issuer,
      title: title,
      purchase_date: purchase_date,
      warranty_expiry_date: warranty_expiry_date
    }
  end

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
    @item.buyer = current_user # ✅ Le créateur devient le premier acheteur

    if @item.save
      if params[:item][:list_ids].present?
        unique_list_ids = params[:item][:list_ids].reject(&:blank?).uniq
        unique_list_ids.each do |list_id|
          ItemList.find_or_create_by(item_id: @item.id, list_id: list_id)
        end
      end
      redirect_to item_path(@item), allow_other_host: true, notice: 'The item has been successfully added.'
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
      redirect_to item_path(@item), allow_other_host: true, notice: 'The item has been successfully updated.'
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

  def sell
    if current_user == @item.buyer
      selling_price = params[:selling_price].to_f

      if selling_price > 0
        if @item.update(for_sale: true, selling_price: selling_price)
          redirect_to @item, notice: "Your item is now listed for sale at #{selling_price}€!"
        else
          redirect_to @item, alert: "Something went wrong. Please try again."
        end
      else
        redirect_to @item, alert: "Please specify a valid selling price."
      end
    else
      redirect_to items_path, alert: "You can't sell an item you don't own!"
    end
  end

  def marketplace
    @items = Item.for_sale

    # Appliquer le filtre de vente
    if params[:selling_status] == "my_items"
      @items = @items.where(buyer_id: current_user.id)
    elsif params[:selling_status] == "others_items"
      @items = @items.where.not(buyer_id: current_user.id)
    end

    # Appliquer le tri
    case params[:sort]
    when 'price_asc'
      @items = @items.order(selling_price: :asc)
    when 'price_desc'
      @items = @items.order(selling_price: :desc)
    when 'newest_first'
      @items = @items.order(created_at: :desc)
    when 'oldest_first'
      @items = @items.order(created_at: :asc)
    end

    # Appliquer les autres filtres
    @items = @items.where(category: params[:category]) if params[:category].present?
    @items = @items.where(condition: params[:condition]) if params[:condition].present?
    @items = @items.where(issuer: params[:issuer]) if params[:issuer].present?

    render :marketplace
  end

  def buy
    if @item.buyer == current_user
      redirect_to marketplace_path, alert: "You already own this item."
    elsif @item.for_sale?
      ActiveRecord::Base.transaction do
        @item.update!(
          buyer: current_user,       # ✅ Le nouvel acheteur devient le propriétaire
          price: @item.selling_price, # ✅ Le selling_price devient le price d'achat
          selling_price: nil,        # ✅ Réinitialisation du prix de vente
          for_sale: false,           # ✅ L'item n'est plus en vente
          list_ids: []               # ✅ L'objet est retiré de ses anciennes listes
        )
      end
      redirect_to @item, notice: "You have successfully purchased this item! You can now manage it."
    else
      redirect_to marketplace_path, alert: "Something went wrong. Try again."
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to marketplace_path, alert: "An error occurred while processing the purchase."
  end

  def unsell
    if @item.buyer != current_user
      redirect_to @item, alert: "You are not the owner of this item."
    elsif @item.update(for_sale: false)
      redirect_to @item, notice: "The item is no longer for sale."
    else
      redirect_to @item, alert: "Something went wrong. Try again."
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
