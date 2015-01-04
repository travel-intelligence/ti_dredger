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

  it "inspects queries" do
    pending("not implemented")
    get_api :show, id: 42
    expect(response.status).to eq(200)
  end
end
