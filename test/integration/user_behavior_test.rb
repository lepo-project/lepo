require 'test_helper'

class UserBehaviorTest < ActionDispatch::IntegrationTest
  test 'signin and signout behaviors' do
    # signin test
    create(:admin_user)
    user = create(:user)
    signin_with '', ''
    assert page.has_selector?('#signin-resource')
    assert_not page.has_selector?('#dashboard-resource')
    signin_with user.signin_name, ''
    assert page.has_selector?('#signin-resource')
    assert_not page.has_selector?('#dashboard-resource')
    signin_with '', user.password
    assert page.has_selector?('#signin-resource')
    assert_not page.has_selector?('#dashboard-resource')
    signin_with user.signin_name, user.password
    assert page.has_selector?('#dashboard-resource')
    assert_not page.has_selector?('#signin-resource')

    # signout test
    click_link 'signout-btn'
    assert page.has_selector?('#signin-resource')
    assert_not page.has_selector?('#dashboard-resource')
  end

  test 'main-nav behaviors' do
    create(:admin_user)
    user = create(:user)
    course = create(:course)
    open_course = create(:open_course)
    create(:course_manager, user_id: user.id, course_id: course.id)
    create(:course_manager, user_id: user.id, course_id: open_course.id)
    signin_with user.signin_name, user.password
    # nav-home
    click_main_nav_item '#nav-home', I18n.t('helpers.note_management'), '#note-resource'
    click_main_nav_item '#nav-home', I18n.t('helpers.support'), '#content-resource'
    click_main_nav_item '#nav-home', I18n.t('helpers.preferences'), '#preference-resource'
    # nav-open-courses
    click_main_nav_item '#nav-open-courses', open_course.title, '#course-resource'
    click_main_nav_item '#nav-open-courses', I18n.t('helpers.portfolio'), '#portfolio-resource'
    click_main_nav_item '#nav-open-courses', I18n.t('helpers.worksheet_note'), '#note-resource'
    click_main_nav_item '#nav-open-courses', I18n.t('activerecord.models.course_member'), '#course-member-resource'
    # nav-repository
    find('#main-nav > #nav-repository').click
    click_main_nav_item '#nav-repository', I18n.t('activerecord.models.content'), '#content-resource'
    click_main_nav_item '#nav-repository', course.title, '#course-resource'
    click_main_nav_item '#nav-repository', I18n.t('helpers.portfolio'), '#portfolio-resource'
    click_main_nav_item '#nav-repository', I18n.t('helpers.worksheet_note'), '#note-resource'
    click_main_nav_item '#nav-repository', I18n.t('activerecord.models.course_member'), '#course-member-resource'
    # signout
    click_link 'signout-btn'
  end

  test 'content creation behavior' do
    create(:admin_user)
    user = create(:user)
    course = create(:course)
    create(:course_manager, user_id: user.id, course_id: course.id)
    signin_with user.signin_name, user.password

    content_creation_from_sub_pane
    content_creation_from_main_pane
    # signout
    click_link 'signout-btn'
  end

  # ====================================================================
  # Functions
  # ====================================================================

  def content_creation_from_sub_pane
    assert_not page.has_selector?('#sub-pane .dropdown-menu')
    click_on('new-resource-btn')
    assert page.has_selector?('#sub-pane .dropdown-menu')
    click_on(I18n.t('layouts.sub_toolbar.new_content'))
    fill_in_content_form true
    click_on('back-btn')
    assert page.has_selector?('#edit-content')
    click_on('submit-btn')
    assert page.has_selector?('#page-file-form')
    click_on('ok-btn')
    assert page.has_selector?('#simple-html-content')
  end

  def content_creation_from_main_pane
    click_main_nav_item '#nav-repository', I18n.t('activerecord.models.content'), '#content-resource'
    assert page.has_selector?('#content-resource')
    click_on('new-content-btn')
    fill_in_content_form true
    click_on('toolbar-back-btn')
    assert page.has_selector?('#edit-content')
    click_on('toolbar-submit-btn')
    assert page.has_selector?('#page-file-form')
    click_on('toolbar-ok-btn')
    assert page.has_selector?('#simple-html-content')
  end

  def fill_in_content_form(new_record)
    expected_selector = new_record ? '#new-content' : '#edit-content'
    assert page.has_selector?(expected_selector)
    content = build(:content)
    assert page.has_selector?('#content-form')
    within('#content-form') do
      fill_in 'content_title', with: content.title
      fill_in 'content_overview', with: content.overview
      click_on 'submit-btn'
    end
    assert page.has_selector?('#page-file-form')
  end
end
