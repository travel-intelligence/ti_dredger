source 'https://rubygems.org'

gem 'rails', '~> 6.0'
gem 'sqlite3'
gem 'puma'
gem 'sqliterate'
gem 'devise'
gem 'resque'
gem 'god'

gem 'cancancan'
gem 'impala'
gem 'cztop'

gem 'ti_sqlegalize', git: 'https://github.com/travel-intelligence/ti_sqlegalize' # '~> 1.0'
gem 'ti_rails_debian', git: 'https://github.com/travel-intelligence/ti_rails_debian'

group :heroku do
  gem 'unicorn'
  gem 'rails_12factor'
end

group :development, :test do
  gem 'spring'
  gem 'rspec-rails'
  gem 'jsonpath'
  gem 'fabrication'
  gem 'mock_redis'
  gem 'byebug'
end
