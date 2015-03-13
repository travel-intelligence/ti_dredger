require 'resque/server'

rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file(rails_root + '/config/resque.yml')
resque_env = resque_config[rails_env]

begin
  Resque.redis = Redis.new(url: "redis://#{resque_env['redis']}")
  Resque.redis.ping
rescue Redis::CannotConnectError => e
  Rails.logger.fatal "Cannot connect to Redis server: #{e.message}"
  raise e
end
