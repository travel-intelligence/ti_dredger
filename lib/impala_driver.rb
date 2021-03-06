require 'impala'
require 'impala_extensions'

Impala::Cursor.prepend ImpalaExtensions::Cursor

# Wrapper around the Impala Gem to control statement execution
module ImpalaDriver

  class Cursor

    delegate :schema, :close, :open?, :each_slice, :has_more?, to: :cursor

    def initialize(connection, properties, statement)
      @cursor = connection.execute(statement, properties)
    end

    private

    attr_reader :cursor
  end

  class Session

    # Maximum number of scanner threads (on each node) used for each query.
    # By default, Impala uses as many cores as are available (one thread per core).
    DEFAULT_NUM_SCANNER_THREADS = 1

    attr_accessor :properties

    def execute(statement)
      Cursor.new(@connection, @properties, statement)
    end

    def initialize(host, port)
      @properties = {
        "NUM_SCANNER_THREADS" => DEFAULT_NUM_SCANNER_THREADS
      }
      @connection = Impala.connect(host, port)
    end
  end

  class Database

    def self.connect(host, port)
      Session.new(host, port)
    end
  end

end
