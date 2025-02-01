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

  def self.category_life_expectancy
    {
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
  end

  def self.lifespan_messages
    {
      "Bedside lamp" => {
        reason: "Bedside lamps have simple electrical components, but wiring and switches degrade over time.",
        risk: "Loose wiring can cause short circuits or fire hazards."
      },
      "Blender" => {
        reason: "Frequent motor use and blade wear contribute to its limited lifespan.",
        risk: "Motor burnout and dull blades can cause inefficiencies and safety risks."
      },
      "Bookshelf" => {
        reason: "Bookshelves last long but are affected by humidity, weight stress, and material aging.",
        risk: "Weak shelves may collapse, causing injury or damage to stored items."
      },
      "Chair" => {
        reason: "Daily use causes material fatigue and weakens joints over time.",
        risk: "A weakened chair can break unexpectedly, leading to falls and injuries."
      },
      "Coffee machine" => {
        reason: "Frequent heating and water exposure cause scale buildup and pump degradation.",
        risk: "Limescale buildup can lead to leaks, overheating, and potential electrical failures."
      },
      "Console" => {
        reason: "Cooling fans, processors, and storage wear out due to heat and frequent use.",
        risk: "Overheating, system crashes, and disk drive failures can occur."
      },
      "Dishwasher" => {
        reason: "Water exposure and moving parts degrade seals, pumps, and heating elements.",
        risk: "Leaks can cause water damage, and mold growth in old seals poses health risks."
      },
      "Dresser" => {
        reason: "Wood and MDF degrade over time due to humidity and drawer friction.",
        risk: "Warping and cracks can make drawers difficult to open or unstable."
      },
      "Electric kettle" => {
        reason: "Mineral deposits from water reduce efficiency, and heating elements degrade.",
        risk: "Old kettles can overheat, leak, or fail to shut off, posing a fire risk."
      },
      "Hi-Fi system" => {
        reason: "Speakers and electronic components wear out due to dust, wiring wear, and aging parts.",
        risk: "Sound distortion, connectivity issues, and electrical failures may occur."
      },
      "Lamp" => {
        reason: "Wiring degradation and switch wear affect longevity.",
        risk: "Old lamps can flicker, short-circuit, or overheat, leading to fire risks."
      },
      "Laptop" => {
        reason: "Battery degradation, software updates, and overheating affect performance.",
        risk: "Battery swelling, slow performance, and security vulnerabilities increase over time."
      },
      "Microwave" => {
        reason: "Magnetron wear, door seal degradation, and electrical aging affect longevity.",
        risk: "Radiation leaks, uneven heating, and fire hazards are possible with old microwaves."
      },
      "Oven" => {
        reason: "Heating elements, thermostats, and insulation degrade over time.",
        risk: "Temperature inconsistencies, gas leaks, or electrical malfunctions can pose safety risks."
      },
      "Piano" => {
        reason: "High-quality wood, metal strings, and felt components are built to last for decades.",
        risk: "Poor maintenance can lead to string tension loss, key misalignment, and sound degradation."
      },
      "Refrigerator" => {
        reason: "Continuous operation wears out compressors and cooling systems.",
        risk: "Higher energy consumption, food spoilage, and coolant leaks are common issues."
      },
      "Shoes" => {
        reason: "Frequent wear leads to sole degradation, material cracking, and loss of support.",
        risk: "Worn-out shoes can cause joint pain and increase the risk of slips and falls."
      },
      "Smartphone" => {
        reason: "Battery degradation, hardware wear, and software obsolescence limit lifespan.",
        risk: "Battery swelling, security risks, and performance issues affect usability."
      },
      "Sofa" => {
        reason: "Cushions, fabric, and frame materials degrade with use and environmental exposure.",
        risk: "Sagging cushions and weakened frames cause discomfort and structural failure."
      },
      "Table" => {
        reason: "Weight pressure, scratches, and joint loosening contribute to wear over time.",
        risk: "A weakened table may collapse under heavy loads, leading to damage or injury."
      },
      "Television" => {
        reason: "Capacitor failure, screen burn-in, and power supply degradation affect longevity.",
        risk: "Dim screens, flickering, or total failure may occur, making the TV unusable."
      },
      "Toaster" => {
        reason: "Heating elements degrade, and crumbs accumulate, reducing efficiency.",
        risk: "Fire hazards increase due to stuck crumbs and failing heating elements."
      },
      "TV stand" => {
        reason: "Heavy materials last long, but weight stress and humidity exposure cause joint weakening.",
        risk: "A weak stand can collapse, leading to damage to the TV and potential injuries."
      },
      "Washing machine" => {
        reason: "Water exposure, motor wear, and drum stress lead to mechanical failures.",
        risk: "Leaks, increased noise, and fire hazards from electrical faults become concerns."
      },
      "Wardrobe" => {
        reason: "Wood and hinges wear over time, and humidity exposure can cause warping.",
        risk: "Unstable doors and weak structures may collapse or fail to close properly."
      }
    }
  end

  private

  def normalize_blank_values
    self.category = nil if category.blank?
    self.issuer = nil if issuer.blank?
  end
end
