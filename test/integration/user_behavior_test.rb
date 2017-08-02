require 'test_helper'

class UserBehaviorTest < ActionDispatch::IntegrationTest
  test 'signin and signout behaviors' do
    # signin test
    create(:user, role: 'admin')
    user = create(:user, role: 'user')
    signin_with '', ''
    assert page.has_selector?('#signin-resource')
    assert_not page.has_selector?('#dashboard-resource')
    signin_with user.user_id, ''
    assert page.has_selector?('#signin-resource')
    assert_not page.has_selector?('#dashboard-resource')
    signin_with '', user.password
    assert page.has_selector?('#signin-resource')
    assert_not page.has_selector?('#dashboard-resource')
    signin_with user.user_id, user.password
    assert page.has_selector?('#dashboard-resource')
    assert_not page.has_selector?('#signin-resource')

    # signout test
    click_link 'signout-btn'
    assert page.has_selector?('#signin-resource')
    assert_not page.has_selector?('#dashboard-resource')
  end

  test 'main-nav behaviors' do
    create(:user, role: 'admin')
    user = create(:user, role: 'user')
    signin_with user.user_id, user.password
    assert page.has_selector?('#dashboard-resource')
    click_main_nav_item I18n.t('views.navs.note_management'), '#snippet-resource'
    click_main_nav_item I18n.t('views.navs.support'), '#content-resource'
    click_main_nav_item I18n.t('views.navs.preferences'), '#preference-resource'
  end

  # ====================================================================
  # Functions
  # ====================================================================
end
