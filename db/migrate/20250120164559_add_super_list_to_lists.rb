class AddSuperListToLists < ActiveRecord::Migration[7.0]
  def change
    add_reference :lists, :super_list, foreign_key: true

    reversible do |dir|
      dir.up do
        # Désactiver les validations et les callbacks pour cette migration
        SuperList.skip_callback(:create, :after, :create_default_lists)

        # Créez les sur-listes par défaut sans utilisateur associé
        super_lists = [
          { title: "Home items", default: true },
          { title: "Everyday life", default: true },
          { title: "Administrative papers", default: true }
        ]

        super_lists.each do |attributes|
          SuperList.create!(attributes.merge(user_id: nil)) # Assure-toi que `user_id` est nullable
        end

        # Réactiver les callbacks
        SuperList.set_callback(:create, :after, :create_default_lists)
      end
    end
  end
end
