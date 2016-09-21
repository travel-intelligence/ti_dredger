# Extensions to the Impala::Cursor class to support schema extraction and
# standard types conversion
module ImpalaExtensions
  module Cursor
    TYPES_MAP = {
      "boolean" => "BOOLEAN",
      "tinyint" => "TINYINT",
      "smallint" => "SMALLINT",
      "int" => "INT",
      "bigint" => "BIGINT",
      "decimal" => "DECIMAL",
      "float" => "FLOAT",
      "double" => "DOUBLE",
      "string" => "VARCHAR",
      "timestamp" => "TIMESTAMP"
    }

    def schema
      metadata.schema.fieldSchemas.map do |f|
        type = TYPES_MAP[f.type]
        fail "Unknown type #{f.type}" unless type
        [f.name, type]
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
