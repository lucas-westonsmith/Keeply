class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :items, dependent: :destroy
  has_many :lists, foreign_key: :user_id, dependent: :destroy
  has_many :list_users, dependent: :destroy
  has_many :shared_lists, through: :list_users, source: :list

  has_one_attached :avatar

  # Validations
  validates :first_name, :last_name, presence: true
  validates :phone_number, format: { with: /\A\+?\d{10,15}\z/, message: "must be a valid phone number" }, allow_blank: true
  validates :country, length: { maximum: 50 }, allow_blank: true
end
