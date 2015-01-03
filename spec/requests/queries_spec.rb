require 'rails_helper'

RSpec.describe "Queries", :type => :request do

  describe "POST /api/v1/queries" do

    it "creates queries" do
      rep = { query: 'select * from t' }.to_json
      headers = { 'CONTENT_TYPE' => 'application/json' }
      post api_v1_queries_path, rep, headers
      expect(response).to have_http_status(201)
    end
  end
end
