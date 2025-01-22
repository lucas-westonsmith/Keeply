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
end
