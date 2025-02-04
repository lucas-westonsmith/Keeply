class AddForSaleToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :for_sale, :boolean, default: false
  end
end
