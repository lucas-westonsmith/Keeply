class ListUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list, only: [:create]
  before_action :set_list_user, only: [:destroy]

  def create
    email = params[:email]
    role = params[:role] || 'collaborator'

    user = User.find_by(email: email)
    if user.nil?
      redirect_to @list, alert: "User with email #{email} does not exist." and return
    end

    if user == current_user
      redirect_to @list, alert: "You cannot add yourself to your own list." and return
    end

    list_user = @list.list_users.build(user: user, role: role)

    if list_user.save
      redirect_to @list, notice: "User with email #{email} has been added to the list."
    else
      redirect_to @list, alert: "Unable to add user. Please try again."
    end
  end

  def destroy
    if @list_user.user == current_user
      redirect_to @list_user.list, alert: "You cannot remove yourself from the list." and return
    end

    @list_user.destroy
    redirect_to @list_user.list, notice: "User has been removed from the list."
  end

  private

  def set_list
    @list = List.find(params[:list_id])
  end

  def set_list_user
    @list_user = ListUser.find(params[:id])
  end
end
