class Item < ApplicationRecord
  belongs_to :user
  has_many :item_lists, dependent: :destroy
  has_many :lists, through: :item_lists
  has_one_attached :photo
  has_one_attached :invoice

  validates :title, presence: true
  validates :issuer, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  enum condition: { poor: 'Poor', okay: 'Okay', good: 'Good', excellent: 'Excellent' }

  before_save :normalize_blank_values

  CATEGORY_MAPPING = {
    # 🏡 Home Items (avec catégories communes)
    "Bedroom" => {
      specific: ["Bed", "Bedside lamp", "Dresser", "Nightstand", "Wardrobe"].sort,
      common: ["Chair", "Hi-Fi system", "Lamp", "Laptop", "Smartphone", "Table", "Television"].sort
    },
    "Kitchen" => {
      specific: ["Blender", "Coffee machine", "Dishwasher", "Electric kettle", "Microwave", "Oven", "Refrigerator", "Toaster", "Washing machine"].sort,
      common: ["Chair", "Hi-Fi system", "Lamp", "Laptop", "Smartphone", "Table", "Television"].sort
    },
    "Living room" => {
      specific: ["Bookshelf", "Console", "Piano", "Sofa", "TV stand", "Television"].sort,
      common: ["Chair", "Hi-Fi system", "Lamp", "Laptop", "Smartphone", "Table"].sort
    },
    "Clothing" => {
      specific: ["Bag", "Hat", "Jacket", "Shirt", "Shoes", "Sunglasses", "Trousers", "Watch"].sort
      # ❌ Pas de Common categories ici
    },

    # 📂 Administrative Papers (avec Subscriptions)
    "Insurance contracts" => {
      specific: ["Car insurance", "Health insurance", "Home insurance", "Legal insurance", "Life insurance", "Travel insurance"].sort
    },
    "Payslips" => {
      specific: ["Bonus", "Monthly salary", "Overtime pay", "Stock options", "Tax refund"].sort
    },
    "Taxes" => {
      specific: ["Business tax", "Income tax", "Property tax", "Social security contributions", "VAT"].sort
    },
    "Subscriptions" => {
      specific: ["Cloud storage", "Internet", "Mobile plan", "Newspaper", "Streaming service", "Software license"].sort
    },

    # 👗 Everyday Life (sans catégories communes)
    "Supermarket" => {
      specific: ["Bakery products", "Cleaning products", "Dairy products", "Drinks", "Fish", "Fruits", "Meat", "Snacks", "Vegetables"].sort
    },
    "Restaurants / Cafés" => {
      specific: ["Casual dining", "Coffee", "Fast food", "Fine dining", "Snacks", "Takeout"].sort
    },
    "Other expenses" => {
      specific: ["Books", "Concert tickets", "Gadgets", "Gym membership", "Miscellaneous", "Streaming service"].sort
    }
  }.freeze

  def self.fetch_categories_for_lists(list_titles)
    specific_categories = []
    common_categories = CATEGORY_MAPPING.values.flat_map { |cat| cat[:common] }.uniq

    list_titles.each do |title|
      if CATEGORY_MAPPING[title]
        specific_categories += CATEGORY_MAPPING[title][:specific]
      end
    end

    { specific: specific_categories.uniq, common: common_categories }
  end

  # Récupère les catégories possibles pour un item en fonction des listes sélectionnées
  def possible_categories
    return { specific: [], common: [] } if lists.empty?

    list_titles = lists.pluck(:title)  # Récupérer les titres des listes sélectionnées
    specific_categories = []
    common_categories = []

    list_titles.each do |title|
      if CATEGORY_MAPPING[title]
        specific_categories += CATEGORY_MAPPING[title][:specific]

        # ✅ On ajoute les Common Categories SEULEMENT si la liste fait partie de Home Items
        if ["Kitchen", "Living-room", "Bedroom", "Clothing"].include?(title)
          common_categories = CATEGORY_MAPPING.values.flat_map { |cat| cat[:common] }.uniq
        end
      end
    end

    { specific: specific_categories.uniq, common: common_categories }
  end

  # Détermine l'image par défaut pour un item
  def default_image
    default_list = lists.find { |list| list.super_list&.default? }

    case default_list&.title
    when 'Living room' then 'living-room-2-default.avif'
    when 'Kitchen' then 'kitchen-2-default.avif'
    when 'Bedroom' then 'bedroom-2-default.avif'
    when 'Clothing' then 'clothing-2-default.avif'
    when 'Supermarket' then 'supermarket-2-default.avif'
    when 'Restaurants / Cafés' then 'restaurant-2-default.avif'
    when 'Other expenses' then 'other-expenses-2-default.avif'
    when 'Subscriptions' then 'subscriptions-2-default.avif'
    when 'Taxes' then 'taxes-2-default.avif'
    when 'Payslips' then 'payslips-2-default.avif'
    when 'Insurance contracts' then 'insurance-2-default.avif'
    else 'default-item.avif'
    end
  end

  def self.find_potentially_obsolete_items(items)
    category_life_expectancy = {
      "Bedside lamp" => 10,
      "Blender" => 8,
      "Bookshelf" => 15,
      "Chair" => 12,
      "Coffee machine" => 7,
      "Console" => 6,
      "Dishwasher" => 11,
      "Dresser" => 15,
      "Electric kettle" => 7,
      "Hi-Fi system" => 9,
      "Lamp" => 10,
      "Laptop" => 4,
      "Microwave" => 8,
      "Oven" => 13,
      "Piano" => 50,
      "Refrigerator" => 12,
      "Shoes" => 5,
      "Smartphone" => 3,
      "Sofa" => 15,
      "Table" => 12,
      "Television" => 8,
      "Toaster" => 7,
      "TV stand" => 15,
      "Washing machine" => 10,
      "Wardrobe" => 15
    }

    potentially_obsolete = []

    items.each do |item|
      next unless item.category.present? && item.purchase_date.present?

      lifespan = category_life_expectancy[item.category]
      next unless lifespan

      years_old = ((Date.today - item.purchase_date).to_f / 365).round(1)

      # **🔥 Ajout de logs pour voir quels items sont analysés**
      puts "🧐 Checking: #{item.title} (Category: #{item.category}, Purchased: #{item.purchase_date}, Age: #{years_old}, Lifespan: #{lifespan})"

      if years_old >= lifespan - 1 # ✅ Modification ici pour tester "Within 1 year"
        puts "⚠️ POTENTIALLY OBSOLETE: #{item.title} (Age: #{years_old} years, Lifespan: #{lifespan})"
        potentially_obsolete << {
          item: item,
          years_old: years_old,
          lifespan: lifespan
        }
      end
    end

    potentially_obsolete
  end

  private

  def normalize_blank_values
    self.category = nil if category.blank?
    self.issuer = nil if issuer.blank?
  end
end
