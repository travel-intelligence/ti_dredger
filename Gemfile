source 'https://rubygems.org'

gem 'rails', '~> 4.2'
gem 'rails-api'
gem 'puma'
gem 'sqliterate'
gem 'resque'
gem 'god'
gem 'impala'
gem 'cztop'
gem 'ti_sqlegalize', git: 'http://github.com/Muriel-Salvan/ti_sqlegalize', branch: 'updated_dependencies'
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
  gem 'mock_redis'
  gem 'byebug'
end
