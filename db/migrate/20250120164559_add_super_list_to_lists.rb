class AddSuperListToLists < ActiveRecord::Migration[7.0]
  def change
    add_reference :lists, :super_list, foreign_key: true

    reversible do |dir|
      dir.up do
        # Désactiver les validations et les callbacks pour éviter les erreurs
        SuperList.skip_callback(:create, :after, :create_default_lists)

        # Assurez-vous qu'un utilisateur existe pour associer les super-listes
        user = User.first || User.create!(
          email: "default@example.com",
          password: "password",
          first_name: "Default",
          last_name: "User",
          date_of_birth: Date.new(1990, 1, 1)
        )

        # Créez les sur-listes par défaut
        super_lists = [
          { title: "Home items", default: true, user: user },
          { title: "Everyday life", default: true, user: user },
          { title: "Administrative papers", default: true, user: user }
        ]
        SuperList.create!(super_lists)

        # Réactiver les callbacks
        SuperList.set_callback(:create, :after, :create_default_lists)
      end
    end
  end
end
