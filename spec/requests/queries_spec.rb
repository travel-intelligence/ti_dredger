require 'rails_helper'

RSpec.describe "Queries API", :type => :request do

  let!(:user) { Fabricate(:user) }

  let!(:auth_headers) do
    { 'From' => user.email,
      'X-Grants' => Base64.encode64({ grants: [{}] }.to_json) }
  end

  describe "POST /v1/queries" do

    it "creates queries from JSON POST body" do
      rep = { queries: { sql: "select * from t" } }.to_json
      headers = { 'Content-Type' => 'application/json' }
      post ti_sqlegalize.queries_path, params: rep, headers: auth_headers.merge(headers)
      expect(response).to have_http_status(201)
    end
  end
end
