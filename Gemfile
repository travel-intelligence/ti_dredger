source 'https://rubygems.org'

gem 'rails', '~> 6.0'
gem 'puma'
gem 'sqliterate'
gem 'resque'
gem 'god'

gem 'impala'
gem 'cztop'

gem 'ti_sqlegalize', git: 'https://github.com/travel-intelligence/ti_sqlegalize'
gem 'ti_rails_auth', git: 'https://github.com/travel-intelligence/ti_rails_auth'
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
