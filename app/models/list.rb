class List < ApplicationRecord
  belongs_to :user
  has_many :item_lists
  has_many :items, through: :item_lists
  has_many :list_users
  has_many :users, through: :list_users
  has_one_attached :photo

  def add_user_by_email(email, role = 'collaborator')
    user = User.find_by(email: email)
    return nil unless user

    list_users.find_or_create_by(user: user, role: role)
  end
end
