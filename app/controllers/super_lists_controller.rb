class SuperListsController < ApplicationController
  before_action :authenticate_user!

  def index
    @super_lists = current_user.super_lists
  end

  def show
    normalized_title = params[:title].gsub('-', ' ')
    @super_list = current_user.super_lists.find_by!(title: normalized_title)
    @lists = @super_list.lists
  end
end
