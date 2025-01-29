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
end
