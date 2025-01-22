class Item < ApplicationRecord
  belongs_to :user
  has_many :item_lists, dependent: :destroy # Supprime les item_lists liés
  has_many :lists, through: :item_lists
  has_one_attached :photo
  has_one_attached :invoice

  validates :title, presence: true
  validates :issuer, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  enum condition: { poor: 'Poor', okay: 'Okay', good: 'Good', excellent: 'Excellent' }

  # Détermine l'image par défaut pour un item
  def default_image
    # Vérifie si l'item appartient à une liste créée par défaut
    default_list = lists.find { |list| list.super_list&.default? }

    # Retourne l'image spécifique à la liste si elle existe
    case default_list&.title
    when 'Living room'
      'living-room-2-default.avif'
    when 'Kitchen'
      'kitchen-2-default.avif'
    when 'Bedroom'
      'bedroom-2-default.avif'
    when 'Clothing'
      'clothing-2-default.avif'
    when 'Supermarket'
      'supermarket-2-default.avif'
    when 'Restaurants / Cafés'
      'restaurant-2-default.avif'
    when 'Other expenses'
      'other-expenses-2-default.avif'
    when 'Subscriptions'
      'subscriptions-2-default.avif'
    when 'Taxes'
      'taxes-2-default.avif'
    when 'Payslips'
      'payslips-2-default.avif'
    when 'Insurance contracts'
      'insurance-2-default.avif'
    else
      # Retourne l'image par défaut générale
      'default-item.avif'
    end
  end
end
