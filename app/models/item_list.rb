class ItemList < ApplicationRecord
  belongs_to :item
  belongs_to :list

  validates :item_id, uniqueness: { scope: :list_id, message: 'is already associated with this list' }
end
