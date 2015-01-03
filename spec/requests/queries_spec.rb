require 'rails_helper'

RSpec.describe "Queries", :type => :request do
  describe "POST /api/v1/queries" do
    it "creates queries" do
      post api_v1_queries_path
      expect(response).to have_http_status(201)
    end
  end
end
