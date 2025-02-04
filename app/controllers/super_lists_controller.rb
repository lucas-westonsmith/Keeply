class SuperListsController < ApplicationController
  before_action :authenticate_user!

  def index
    @super_lists = current_user.super_lists
  end

  def show
    normalized_title = params[:title].gsub('-', ' ')
    @super_list = current_user.super_lists.find_by!(title: normalized_title)

    # Listes créées par l'utilisateur (qui ont le bon super_list_id)
    user_lists = @super_list.lists

    # Listes auxquelles il est invité (elles ont potentiellement un super_list_id différent)
    invited_lists = List.joins(:list_users)
                        .where(list_users: { user_id: current_user.id })
                        .joins(:super_list)
                        .where(super_lists: { title: @super_list.title }) # Match sur le nom du SuperList

    # On fusionne les deux et on évite les doublons
    @lists = (user_lists + invited_lists).uniq

    # Debugging logs
    puts "🔵 SuperList trouvé : #{@super_list.title} (ID: #{@super_list.id})"
    puts "👤 Utilisateur actuel : #{current_user.id} (#{current_user.email})"
    puts "📜 Toutes les listes de ce super_list (créées par user) : #{user_lists.pluck(:id, :title)}"
    puts "📌 Listes invitées correspondant à ce super_list : #{invited_lists.pluck(:id, :title)}"
    puts "✅ Listes finales accessibles : #{@lists.pluck(:id, :title)}"
  end
end
