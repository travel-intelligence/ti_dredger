source 'https://rubygems.org'

ruby '2.2.0'

gem 'rails', '4.2.0'
gem 'rails-api'
gem 'puma'
gem 'sqliterate'
gem 'ti_sqlegalize', github: 'ebastien/ti_sqlegalize'
gem 'ti_rails_auth', github: 'ebastien/ti_rails_auth'

group :heroku do
  gem 'unicorn'
  gem 'rails_12factor'
end

group :development, :test do
  gem 'spring'
  gem 'rspec-rails'
  gem 'jsonpath'
  gem 'fabrication'
  gem 'ti_rails_debian', github: 'ebastien/ti_rails_debian'
end
