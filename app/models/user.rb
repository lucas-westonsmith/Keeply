class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

         has_many :items
         has_many :lists, foreign_key: :user_id
         has_many :list_users
         has_many :shared_lists, through: :list_users, source: :list
end
