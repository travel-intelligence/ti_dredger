require 'rails_helper'

RSpec.describe Api::V1::QueriesController, :type => :controller do

  it "creates queries" do
    query = "select * from t"
    post_api :create, query: query
    expect(response.status).to eq(201)
    location = response.headers['Location']
    expect(location).not_to be_blank
    expect(first_json_at '$.queries.href').to eq(location)
    expect(first_json_at '$.queries.sql').to eq(query)
    expect(first_json_at '$.queries.id').not_to be_nil
  end

  it "complains on missing query" do
    post_api :create
    expect(response.status).to eq(400)
  end

  it "complains on invalid query" do
    query = "this is not a valid SQL query"
    post_api :create, query: query
    expect(response.status).to eq(400)
  end

  it "extract all tables from a valid query" do
    query = "select a from t1, (select b,c from d.t) t2"
    post_api :create, query: query
    expect(response.status).to eq(201)
    expect(first_json_at '$.queries.tables').to eq(["d.t", "t1"])
  end

  it "inspects queries" do
    pending("not implemented")
    get_api :show, id: 42
    expect(response.status).to eq(200)
  end
end
