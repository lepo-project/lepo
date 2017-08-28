require 'test_helper'

class SuspendedUserBehaviorTest < ActionDispatch::IntegrationTest
  test 'signin behavior' do
    # signin test
    create(:admin_user)
    user = create(:suspended_user)
    signin_with user.signin_name, user.password
    assert page.has_selector?('#signin-resource')
    assert_not page.has_selector?('#dashboard-resource')
  end
end
