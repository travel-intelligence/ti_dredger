rails_root = File.expand_path('../..', __FILE__)
rails_env = "production"
resque_config = YAML.load_file(rails_root + '/config/resque.yml')
workers = resque_config[rails_env]["workers"] || 1

God.pid_file_directory = "#{rails_root}/tmp"

workers.times do |n|
  God.watch do |w|
    w.dir      = rails_root
    w.name     = "resque-#{n}"
    w.group    = 'resque'
    w.interval = 30.seconds
    w.env      = { "QUEUE" => "*", "RAILS_ENV" => rails_env, "VERBOSE" => "1" }
    w.start    = "./bin/rake resque:work"
    w.log      = "#{rails_root}/log/resque-#{n}.log"
    w.keepalive
  end
end
