class AddSuperListToLists < ActiveRecord::Migration[7.0]
  def change
    add_reference :lists, :super_list, foreign_key: true

    reversible do |dir|
      dir.up do
        # Assurez-vous qu'un utilisateur existe pour associer les super-listes
        user = User.first || User.create!(
          email: "default@example.com",
          password: "password",
          first_name: "Default",
          last_name: "User",
          date_of_birth: Date.new(1990, 1, 1)
        )

        # Désactiver les callbacks
        SuperList.skip_callback(:create, :after, :create_default_lists)

        # Créez les sur-listes par défaut sans validations
        super_lists = [
          { title: "Home items", default: true, user: user },
          { title: "Everyday life", default: true, user: user },
          { title: "Administrative papers", default: true, user: user }
        ]

        super_lists.each do |attributes|
          SuperList.create!(attributes) # Désactiver les validations
        end

        # Réactiver les callbacks
        SuperList.set_callback(:create, :after, :create_default_lists)
      end
    end
  end
end
