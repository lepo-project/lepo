require 'test_helper'

class SuspendedUserBehaviorTest < ActionDispatch::IntegrationTest
  test 'signin behavior' do
    # signin test
    create(:user, role: 'admin')
    user = create(:user, role: 'suspended')
    signin_with user.user_id, user.password
    assert page.has_selector?('#signin-resource')
    assert_not page.has_selector?('#dashboard-resource')
  end
end
