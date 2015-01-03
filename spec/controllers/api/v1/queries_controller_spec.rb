require 'rails_helper'

RSpec.describe Api::V1::QueriesController, :type => :controller do

  it "creates queries" do
    post_api :create, query: "select * from t"
    expect(response.status).to eq(201)
  end
end
