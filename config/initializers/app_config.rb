class Settings
  def self.app
    @app
  end

  def self.load!
    config_dir = Rails.configuration.paths['config'].first
    config_file = File.join config_dir, 'application.yml'
    begin
      @app = YAML.load_file config_file
    rescue LoadError, Errno::ENOENT => e
      raise "Could not load application configuration: #{e}"
    end
  end
end

Rails.application.configure do
  Settings.load!
  config.x.root_path = Settings.app['root_path'] || '/'
  config.x.calcite_endpoint = Settings.app['calcite_endpoint']
  config.x.domains_file = Settings.app['domains_file']
  config.x.schemas_file = Settings.app['schemas_file']
  config.x.abilities_file = Settings.app['abilities_file']
  config.filter_parameters << :password
  Rails.application.routes.default_url_options[:host] = Settings.app['host']
  config.action_controller.default_url_options = { protocol: Settings.app['protocol'] }
end
