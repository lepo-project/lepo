ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'
require 'capybara/minitest'
require 'database_cleaner'

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def assert_invalid(instance, property)
    assert instance.invalid?
    assert instance.errors.messages[property].any?
  end
end

class ActionDispatch::IntegrationTest
  # For all integration tests with FactoryBot + Capybara + JS driver
  self.use_transactional_tests = false

  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  # Make `assert_*` methods behave like Minitest assertions
  include Capybara::Minitest::Assertions

  # Use chrome driver for Capybara
  # To force-upgrade to the latest version of chromedriver:
  #   delete the directory $HOME/.chromedriver-helper
  #   run chromedriver-update
  Capybara.default_driver = :selenium
  Capybara.register_driver :selenium do |app|
    # Capybara::Selenium::Driver.new(app, browser: :chrome)
    # For headless chrome browser
    Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(chrome_options: { args: %w[headless disable-gpu window-size=1680,1050] }))
  end

  DatabaseCleaner.strategy = :truncation

  def setup
    # Database cleaner
    DatabaseCleaner.start
  end

  def teardown
    # Reset sessions and driver between tests
    visit root_path
    Capybara.reset_sessions!
    Capybara.use_default_driver
    DatabaseCleaner.clean
  end

  def assert_invalid(instance, property)
    assert instance.invalid?
    assert instance.errors.messages[property].any?
  end

  def click_main_nav_item(nav_id, link_text, assertion_selector)
    within('#main-nav > ' + nav_id) do
      click_on(link_text)
    end
    assert page.has_selector?(assertion_selector)
  end

  def signin_with(signin_name, password)
    visit root_path
    within('#signin-form') do
      fill_in 'signin_name', with: signin_name
      fill_in 'password', with: password
      click_on 'signin-submit-btn'
    end
  end
end
