class SuperList < ApplicationRecord
  belongs_to :user
  has_many :lists, dependent: :destroy

  validates :title, presence: true
  validates :title, inclusion: { in: ['Home items', 'Everyday life', 'Administrative papers'] }, if: :default?
  validates :title, uniqueness: { scope: :user_id, message: 'already exists for this user' }
  validates :default, inclusion: { in: [true, false] }

  before_create :ensure_unique_super_list
  before_destroy :prevent_default_deletion
  before_validation :set_default_description, on: :create
  after_create :create_default_lists, if: :default?

  private

  def prevent_default_deletion
    throw(:abort) if default?
  end

  def set_default_description
    self.description ||= case title
                         when 'Home items'
                           'Organize all your home-related items, such as furniture, appliances, decorations, and clothing.'
                         when 'Everyday life'
                           'Track your one-time expenses, such as supermarket purchases, restaurants, and cafés.'
                         when 'Administrative papers'
                           'Keep all your administrative documents organized, including subscriptions, taxes, payslips, and insurance contracts.'
                         else
                           'No description available.'
                         end
  end

  def create_default_lists
    return if lists.exists?

    case title
    when 'Home items'
      create_list_with_image('Living room', 'living-room-default.avif', 'Organize your furniture, decorations, and appliances for the living room.')
      create_list_with_image('Kitchen', 'kitchen-default.avif', 'Keep track of kitchen equipment, tools, and appliances.')
      create_list_with_image('Bedroom', 'bedroom-default.avif', 'Maintain an inventory of bedroom furniture, bedding, and other essentials.')
      create_list_with_image('Clothing', 'clothing-default.avif', 'Organize and track your wardrobe and clothing items.')
    when 'Everyday life'
      create_list_with_image('Supermarket', 'supermarket-default.avif', 'Track your grocery shopping and supermarket expenses.')
      create_list_with_image('Restaurants / Cafés', 'restaurant-default.avif', 'Organize your dining and café expenses.')
      create_list_with_image('Other expenses', 'other-expenses-default.avif', 'Manage miscellaneous everyday expenses.')
    when 'Administrative papers'
      create_list_with_image('Subscriptions', 'subscriptions-default.avif', 'Keep track of subscription services and related documents.')
      create_list_with_image('Taxes', 'taxes-default.avif', 'Organize your tax documents and related paperwork.')
      create_list_with_image('Payslips', 'payslips-default.avif', 'Store and manage all your payslips securely.')
      create_list_with_image('Insurance contracts', 'insurance-default.avif', 'Keep a record of all your insurance contracts and policies.')
    end
  end

  def create_list_with_image(title, image_filename, description)
    list = lists.create(title: title, user: user, description: description)
    if list.persisted?
      list.photo.attach(
        io: File.open(Rails.root.join('app', 'assets', 'images', image_filename)),
        filename: image_filename,
        content_type: 'image/avif'
      )
    end
  end

  def ensure_unique_super_list
    if SuperList.exists?(user: user, title: title)
      errors.add(:base, "Super list with title '#{title}' already exists for this user")
      throw(:abort)
    end
  end
end
