class AddSuperListToLists < ActiveRecord::Migration[7.0]
  def change
    # Ajoutez la colonne sans contrainte NOT NULL
    add_reference :lists, :super_list, foreign_key: true

    # Après avoir ajouté la colonne, mettez à jour les enregistrements existants pour leur attribuer une valeur
    reversible do |dir|
      dir.up do
        default_super_list = SuperList.find_or_create_by!(title: 'Default', user: User.first) # Remplacez par un cas par défaut logique
        List.update_all(super_list_id: default_super_list.id) # Assurez-vous que chaque liste a une sur-liste
      end
    end

    # Appliquez la contrainte NOT NULL
    change_column_null :lists, :super_list_id, false
  end
end
