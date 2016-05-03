require 'impala'
require 'ti_sqlegalize/zmq_socket'
require 'ti_sqlegalize/calcite_validator'
require 'ti_sqlegalize/sqliterate_validator'
require 'active_support/json'

label = "#{Rails.env}_hadoop"
config = Rails.configuration.database_configuration[label]

unless config && config['host'] && config['port']
  fail KeyError, "No Impala configuration found for #{label}"
end

module Impala
  class Cursor
    KNOWN_TYPES = %w(
      string boolean tinyint smallint int bigint double float decimal timestamp
    )

    def schema
      metadata.schema.fieldSchemas.map do |f|
        fail "Unknown type: #{f.type}" unless KNOWN_TYPES.include? f.type
        [f.name, f.type]
      end
    end

    def parse_row(raw)
      fields = raw.split(metadata.delim)
      metadata.schema.fieldSchemas.zip(fields).map do |schema, raw_value|
        convert_raw_value(raw_value, schema)
      end
    end
  end
end

TiSqlegalize.database = if Rails.env.test?
                          -> { TiSqlegalize::DummyDatabase.new }
                        else
                          -> { Impala.connect(config['host'], config['port']) }
                        end

TiSqlegalize.validator = \
  if Rails.configuration.x.calcite_endpoint && !Rails.env.test?
    -> do
      socket = TiSqlegalize::ZMQSocket.new(Rails.configuration.x.calcite_endpoint)
      TiSqlegalize::CalciteValidator.new(socket)
    end
  else
    -> { TiSqlegalize::SQLiterateValidator.new }
  end

TiSqlegalize.schemas = \
  if Rails.configuration.x.schemas_file
    -> do
      begin
        ActiveSupport::JSON.decode File.read(Rails.configuration.x.schemas_file)
      rescue JSON::ParserError, Errno::ENOENT => e
        raise "Could not load schemas: #{e}"
      end
    end
  else
    -> { [] }
  end
