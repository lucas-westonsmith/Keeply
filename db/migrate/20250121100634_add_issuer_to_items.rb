class AddIssuerToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :issuer, :string
  end
end
