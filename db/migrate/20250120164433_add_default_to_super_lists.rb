class AddDefaultToSuperLists < ActiveRecord::Migration[7.1]
  def change
    add_column :super_lists, :default, :boolean, default: false
  end
end
