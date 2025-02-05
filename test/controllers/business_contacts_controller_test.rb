require "test_helper"

class BusinessContactsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get business_contacts_create_url
    assert_response :success
  end
end
