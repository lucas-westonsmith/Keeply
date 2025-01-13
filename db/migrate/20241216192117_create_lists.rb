class CreateLists < ActiveRecord::Migration[7.1]
  def change
    create_table :lists do |t|
      t.string :title
      t.text :description
      t.string :picture
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
