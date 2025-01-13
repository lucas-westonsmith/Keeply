class ListUsersController < ApplicationController
  before_action :authenticate_user!

  def create
    @list = List.find(params[:list_id])
    @user = User.find(params[:user_id])

    # Création d'un nouveau membre dans la liste avec rôle par défaut (collaborateur)
    @list_user = ListUser.new(list: @list, user: @user, role: "collaborator")

    if @list_user.save
      redirect_to @list, notice: 'L\'utilisateur a été ajouté à la liste.'
    else
      redirect_to @list, alert: 'Erreur lors de l\'ajout de l\'utilisateur à la liste.'
    end
  end

  def destroy
    @list_user = ListUser.find(params[:id])
    @list_user.destroy
    redirect_to @list_user.list, notice: 'L\'utilisateur a été supprimé de la liste.'
  end
end
