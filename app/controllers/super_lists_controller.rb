class SuperListsController < ApplicationController
  before_action :authenticate_user!

  def index
    @super_lists = current_user.super_lists
  end

  def show
    @super_list = current_user.super_lists.find_by!(title: params[:title])
    @lists = @super_list.lists
  end
end
