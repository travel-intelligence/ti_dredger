source 'https://rubygems.org'

ruby '2.7.1'

gem 'rails' #, '4.2.0'
gem 'rails-api'
gem 'puma'
gem 'sqliterate'
gem 'resque'
gem 'god'
gem 'impala' #, '0.4.3'
gem 'cztop' #, '0.6.1'
gem 'ti_sqlegalize', git: 'https://github.com/travel-intelligence/ti_sqlegalize' #, tag: 'v0.1.4'
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
end
