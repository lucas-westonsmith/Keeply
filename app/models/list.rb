class List < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :super_list
  has_many :item_lists
  has_many :items, through: :item_lists
  has_many :list_users
  has_many :users, through: :list_users
  has_one_attached :photo

  # Validations
  validates :title, presence: true, uniqueness: { scope: :user, message: "You already have a list with this title" }
  validates :super_list, presence: true

  # Méthodes
  def add_user_by_email(email, role = 'collaborator')
    user = User.find_by(email: email)
    return nil unless user

    list_users.find_or_create_by(user: user, role: role)
  end
end
