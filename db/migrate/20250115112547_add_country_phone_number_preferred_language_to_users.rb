class AddCountryPhoneNumberPreferredLanguageToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :country, :string
    add_column :users, :phone_number, :string
    add_column :users, :preferred_language, :string
  end
end
