class AddBuyerToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :buyer_id, :integer
  end
end
