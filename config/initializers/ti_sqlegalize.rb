require 'impala_driver'
require 'ti_sqlegalize/zmq_socket'
require 'ti_sqlegalize/calcite_validator'
require 'ti_rails_auth/controller'
require 'active_support/json'

Rails.application.configure do

  db_label = "#{Rails.env}_hadoop"
  db_config = Rails.configuration.database_configuration[db_label]

  unless db_config && db_config['host'] && db_config['port']
    fail KeyError, "No Impala configuration found for #{db_label}"
  end

  config.ti_sqlegalize.auth_mixin = '::TiRailsAuth::Controller'

  if config.use_impala
    Rails.logger.info "Use Impala database behind #{db_config['host']}:#{db_config['port']}"
    config.ti_sqlegalize.database = -> do
      ImpalaDriver::Database.connect(db_config['host'], db_config['port'])
    end
  end

  if config.use_calcite && Rails.configuration.x.calcite_endpoint
    Rails.logger.info "Use Calcite SQL parser behind #{Rails.configuration.x.calcite_endpoint}"
    config.ti_sqlegalize.validator = -> do
      socket = TiSqlegalize::ZMQSocket.new(Rails.configuration.x.calcite_endpoint)
      TiSqlegalize::CalciteValidator.new(socket)
    end
  end

  if Rails.configuration.x.domains_file
    Rails.logger.info "Use domains file #{Rails.configuration.x.domains_file}"
    domains = TiSqlegalize::DomainDirectory.load(
                File.join(
                  Rails.root, Rails.env.test? ? 'spec' : 'config',
                  Rails.configuration.x.domains_file
                )
              )
    config.ti_sqlegalize.domains = -> { domains }
  end

  if Rails.configuration.x.schemas_file
    Rails.logger.info "Use schemas file #{Rails.configuration.x.schemas_file}"
    schemas = TiSqlegalize::SchemaDirectory.load(
                File.join(
                  Rails.root, Rails.env.test? ? 'spec' : 'config',
                  Rails.configuration.x.schemas_file
                )
              )
    config.ti_sqlegalize.schemas = -> { schemas }
  end
end
