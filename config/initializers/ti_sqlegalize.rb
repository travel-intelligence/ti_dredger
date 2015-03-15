require 'impala'

label = "#{Rails.env}_hadoop"
config = Rails.configuration.database_configuration[label]

unless config && config['host'] && config['port']
  fail KeyError, "No Impala configuration found for #{label}"
end

module Impala
  class Cursor
    def schema
      metadata.schema.fieldSchemas.map(&:name)
    end

    def parse_row(raw)
      fields = raw.split(metadata.delim)
      metadata.schema.fieldSchemas.zip(fields).map do |schema, raw_value|
        convert_raw_value(raw_value, schema)
      end
    end
  end
end

TiSqlegalize.database = if Rails.env == 'test'
                          -> { TiSqlegalize::DummyDatabase.new }
                        else
                          -> { Impala.connect(config['host'], config['port']) }
                        end
