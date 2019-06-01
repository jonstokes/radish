source 'https://rubygems.org'
ruby "2.6.3"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.2.3'
gem 'pg'
gem 'puma'
gem 'jbuilder'
gem 'uglifier', '>= 1.3.0'
gem 'mint2qif', github: 'jonstokes/mint2qif'
gem 'draper', github: 'drapergem/draper'
gem 'foreman'
gem "honeybadger"
gem 'devise'
gem "font-awesome-rails"
gem "interactor-rails", "~> 2.0"
gem "lasershark"
gem "money-rails"
gem "kaminari"
gem "sidekiq"
gem "activeadmin"

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem "pry-rails"
  gem 'dotenv-rails'
end

group :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'database_cleaner'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen'
end

group :production, :staging do
  gem "rails_12factor"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
