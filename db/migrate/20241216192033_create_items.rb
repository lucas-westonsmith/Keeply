class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.string :title
      t.text :description
      t.decimal :price
      t.string :condition
      t.string :category
      t.references :user, null: false, foreign_key: true
      t.date :purchase_date
      t.date :warranty_expiry_date

      t.timestamps
    end
  end
end
