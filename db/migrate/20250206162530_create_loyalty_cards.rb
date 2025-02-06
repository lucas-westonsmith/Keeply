class CreateLoyaltyCards < ActiveRecord::Migration[7.1]
  def change
    create_table :loyalty_cards do |t|
      t.references :user, null: false, foreign_key: true
      t.string :card_number
      t.string :barcode_data

      t.timestamps
    end
    add_index :loyalty_cards, :card_number, unique: true
  end
end
