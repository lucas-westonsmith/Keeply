require "test_helper"

class SuperListsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get super_lists_index_url
    assert_response :success
  end

  test "should get show" do
    get super_lists_show_url
    assert_response :success
  end
end
