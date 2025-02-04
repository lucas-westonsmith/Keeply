class AddSellingPriceToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :selling_price, :decimal
  end
end
