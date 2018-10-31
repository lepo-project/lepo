source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Fix autoprefixer-rails verstion 8 to precompile assets with therubyracer
gem 'autoprefixer-rails', '~>8.6.5'
gem 'autosize', '~> 2.4'
gem 'bootstrap', '~> 4.1.0'
# gem "chartkick"
gem 'coffee-rails', '~> 4.2.0'
gem 'combine_pdf', '~> 1.0.7'
gem 'font-awesome-rails', '~> 4.7'
gem 'http_accept_language', '~> 2.1.0'
gem 'image_processing', '~> 1.6.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
gem 'jquery-hotkeys-rails', '~> 0.7.9'
gem 'jquery-rails', '~> 4.3.0'
gem 'jquery-ui-rails', '~> 6.0.0'
gem 'net-ldap', '~> 0.16.0'
gem 'paperclip', '~> 6.0.0'
gem 'pdfjs_viewer-rails', '~> 0.2.8', github: 'lepo-project/pdfjs_viewer-rails'
gem 'rails', '~> 5.0.4'
gem 'rails-assets-tether', '~> 1.1'
gem 'rails_autolink'
gem 'remotipart', '~> 1.4.2'
# FIXME: PushNotification
gem 'rest-client', '~> 2.0.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.6'
gem 'shrine', '~> 2.11.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 4.1.14'
gem 'whenever', require: false

group :development, :test do
  gem 'sqlite3', '~> 1.3.0'
end

group :development do
  gem 'annotate', '~> 2.7.0'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'i18n_generators', '~> 2.2.0'
  gem 'listen', '~> 3.1.0'
  # meta_request is necessary for rails_panel chrome extension
  # gem 'meta_request'
  gem 'rubocop', require: false
  gem 'scss_lint', '~> 0.57.0', require: false
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.6.0'
end

group :test do
  gem 'capybara', '~> 2.17.0'
  gem 'chromedriver-helper'
  gem 'database_cleaner', '~> 1.6.0'
  gem 'factory_bot_rails', '~> 4.8'
  gem 'minitest-capybara'
  gem 'selenium-webdriver', '~> 3.4'
end

group :production do
  gem 'mysql2', '~> 0.4.0'
  # Use Puma as the app server
  # gem 'puma', '~> 3.0'
  # Use Unicorn as the app server
  gem 'unicorn', '~> 5.4.0'
end
