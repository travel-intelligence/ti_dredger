require 'rails_helper'

describe Impala::Cursor do

  class MockField < Struct.new(:name, :type)
  end

  before(:each) do
    @connection = double("Impala connection")
    @handle = double("Impala handle")
    @service = double("Impala service")
    @result = double("Impala result")
    @data = []
    @metadata = double("Impala metadata")
    @schema = double("Impala schema")
    @field = double("Impala field")
    @field_schemas = [
      MockField.new('a', 'string'),
      MockField.new('b', 'int')
    ]

    allow(@field).to receive(:type).and_return("string")

    allow(@schema).to receive(:fieldSchemas).and_return(@field_schemas)

    allow(@metadata).to receive(:schema).and_return(@schema)

    allow(@result).to receive(:data).and_return(@data)
    allow(@result).to receive(:has_more).and_return(false)

    allow(@service).to receive(:fetch).and_return(@result)
    allow(@service).to receive(:close)
    allow(@service).to receive(:get_results_metadata).and_return(@metadata)

    allow(@connection).to receive(:execute) do
      Impala::Cursor.new(@handle, @service)
    end

    allow(Impala::Connection).to receive(:new).and_return(@connection)
  end

  it "returns the schema of a query" do
    db = Impala.connect('127.0.0.1', '21000')
    cursor = db.execute 'select a, b from t'
    expect(cursor.schema).to eq([
        [ 'a', 'VARCHAR' ],
        [ 'b', 'INTEGER' ]
      ])
  end
end
