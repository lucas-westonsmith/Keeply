class LoyaltyCardsController < ApplicationController
  before_action :authenticate_user!

  def show
    @loyalty_card = current_user.loyalty_card || current_user.create_loyalty_card

    if @loyalty_card.nil?
      flash[:alert] = "Your loyalty card could not be found."
      redirect_to root_path
    end
  end
end
