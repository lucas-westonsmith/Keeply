class List < ApplicationRecord
  belongs_to :user
  has_many :item_lists
  has_many :items, through: :item_lists
  has_many :list_users
  has_many :users, through: :list_users
  has_one_attached :photo
end
