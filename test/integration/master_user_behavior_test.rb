require 'test_helper'

class MasterUserBehaviorTest < ActionDispatch::IntegrationTest
  test 'setup / signin page behavior' do
    # before initial setup
    visit root_path
    assert page.has_selector?('#setup-resource')
    assert_not page.has_selector?('#signin-resource')

    # after initial setup
    create(:admin_user)
    visit root_path
    assert page.has_selector?('#signin-resource')
    assert_not page.has_selector?('#setup-resource')
  end

  test 'course creation behavior' do
    user = create(:admin_user)
    signin_with user.signin_name, user.password
    assert page.has_selector?('#dashboard-resource')

    course_creation_from_sub_pane
    course_creation_from_main_pane
    # signout
    click_link 'signout-btn'
  end

  # ====================================================================
  # Private Functions
  # ====================================================================
  private

  def course_creation_from_sub_pane
    term = create(:term)

    assert_not page.has_selector?('#sub-pane .dropdown-menu')
    click_on('new-resource-btn')
    assert page.has_selector?('#sub-pane .dropdown-menu')
    click_on(I18n.t('layouts.sub_toolbar.new_course'))
    fill_in_course_form term, true
    click_on('back-btn')
    assert page.has_selector?('#edit-course')
    click_on('submit-btn')
    assert page.has_selector?('#edit-lessons')
    click_on('ok-btn')
    assert page.has_selector?('#course-resource')
  end

  def course_creation_from_main_pane
    term = create(:term)

    click_main_nav_item '#nav-home', I18n.t('helpers.preferences'), '#preference-resource'
    assert page.has_selector?('#preference-resource')
    click_on('new-course-pref')
    fill_in_course_form term, true
    click_on('toolbar-back-btn')
    assert page.has_selector?('#edit-course')
    click_on('toolbar-submit-btn')
    assert page.has_selector?('#edit-lessons')
    click_on('toolbar-ok-btn')
    assert page.has_selector?('#course-resource')
  end

  def fill_in_course_form(term, new_record)
    expected_selector = new_record ? '#new-course' : '#edit-course'
    assert page.has_selector?(expected_selector)
    course = build(:course)
    assert page.has_selector?('#course-form')
    within('#course-form') do
      fill_in 'course_title', with: course.title
      select term.title, from: 'course_term_id'
      fill_in 'course_overview', with: course.overview
      # click_on('running_title')
      click_on 'submit-btn'
    end
    assert page.has_selector?('#edit-lessons')
  end
end
