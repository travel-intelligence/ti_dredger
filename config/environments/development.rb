Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  # config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  # config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Use Calcite to parse SQL
  config.use_calcite = true

  # Use Impala as a database
  config.use_impala = false

  # When an error occurs in development mode, render debugging information as
  # a regular API response, not an HTML page.
  config.debug_exception_response_format = :api

  # Set the host
  Rails.application.routes.default_url_options[:host] = 'http://localhost:9292'

  # List of users that can be auto-logged, or false for no auto-login.
  # NEVER USE THAT IN PRODUCTION!
  config.allow_autologin = ['dev_user']

  # Set of database queries to be mocked by the TiSqlegalize DummyDatabase, or false to not mock anything.
  # Only used if use_impala is false.
  config.mock_statements = {
    "SELECT `BOARD_CITY`\nFROM `MARKET`.`BOOKINGS_OND`" => {
      schema: [['BOARD_CITY', 'IATA_CITY']],
      data: [
        ['NCE'],
        ['CDG'],
        ['MAD']
      ]
    }
  }

end
