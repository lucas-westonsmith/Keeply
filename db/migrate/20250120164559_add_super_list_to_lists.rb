class AddSuperListToLists < ActiveRecord::Migration[7.0]
  def change
    add_reference :lists, :super_list, foreign_key: true

    reversible do |dir|
      dir.up do
        # Créer un utilisateur par défaut si aucun n'existe
        user = User.first || User.create!(
          email: "default@example.com",
          password: "password",
          first_name: "Default",
          last_name: "User",
          date_of_birth: Date.new(1990, 1, 1)
        )

        # Désactiver temporairement les validations de modèle
        SuperList.reset_column_information
        super_lists = [
          { title: "Home items", default: true, user_id: user.id },
          { title: "Everyday life", default: true, user_id: user.id },
          { title: "Administrative papers", default: true, user_id: user.id }
        ]

        super_lists.each do |attributes|
          unless SuperList.exists?(title: attributes[:title], user_id: attributes[:user_id])
            SuperList.create!(attributes)
          end
        end
      end
    end
  end
end
