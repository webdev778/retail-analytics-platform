source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0'
# Database
gem 'pg'
# gem 'postgres_ext'
# gem 'foreigner'
gem 'composite_primary_keys'

# Users
gem 'devise', '~> 4.2.0'
gem 'cancancan'

gem 'bootstrap-sass', '~> 3.2.0'
gem 'autoprefixer-rails'

gem 'simple_form'

gem 'paperclip'

# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use HAML for .html.haml assets and views
gem 'hamlit'
gem 'hamlit-rails'

gem 'figaro'

gem 'peddler'

gem 'roo'

gem 'sidekiq'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'rspec-rails'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'selenium-webdriver'
  gem 'rails-controller-testing'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'rubocop', require: false
  gem 'bullet', group: :development
  gem 'better_errors', group: :development
  gem 'binding_of_caller', group: :development
end

group :test do
  gem 'shoulda-matchers', require: false
  gem 'rspec-sidekiq'
  gem 'timecop'
  gem 'simplecov', require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

