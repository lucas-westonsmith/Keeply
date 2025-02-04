class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :pricing]

  def home
  end

  def profile
    redirect_to new_user_session_path unless user_signed_in?
    @user = current_user
  end

  def pricing
  end
end
