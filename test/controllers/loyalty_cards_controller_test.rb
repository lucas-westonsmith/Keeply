require "test_helper"

class LoyaltyCardsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get loyalty_cards_show_url
    assert_response :success
  end
end
