require File.expand_path('../boot', __FILE__)

# require 'rails/all'
require 'uri'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TiDredger
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true

    # Tell Rails this is an API app since rails-api was merged into Rails
    config.api_only = true

    # Add strategies as part of the autoload paths
    config.autoload_paths += Dir["#{config.root}/app/strategies/"]

    # Don't use content_type anymore
    config.action_dispatch.return_only_media_type_on_content_type = false

  end
end
