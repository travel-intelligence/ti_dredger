source 'https://rubygems.org'

ruby '2.2.0'

gem 'rails', '4.2.0'

gem 'rails-api'

gem 'unicorn'

gem 'sqliterate'

gem 'ti_sqlegalize', path: '../ti_sqlegalize'

group :production do
  # Heroku platform
  gem 'rails_12factor'
end

group :development, :test do
  gem 'spring'
  gem 'rspec-rails'
  gem 'jsonpath'
end
