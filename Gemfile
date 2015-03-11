source 'https://rubygems.org'

ruby '2.2.1'

gem 'rails', '4.2.0'
gem 'rails-api'
gem 'puma'
gem 'sqliterate'
gem 'ti_sqlegalize', git: 'http://github.com/ebastien/ti_sqlegalize'
gem 'ti_rails_auth', git: 'http://github.com/ebastien/ti_rails_auth'
gem 'ti_rails_debian', git: 'http://github.com/ebastien/ti_rails_debian'

group :heroku do
  gem 'unicorn'
  gem 'rails_12factor'
end

group :development, :test do
  gem 'spring'
  gem 'rspec-rails'
  gem 'jsonpath'
  gem 'fabrication'
end
