class CreateItemLists < ActiveRecord::Migration[7.1]
  def change
    create_table :item_lists do |t|
      t.references :item, null: false, foreign_key: true
      t.references :list, null: false, foreign_key: true

      t.timestamps
    end
  end
end
