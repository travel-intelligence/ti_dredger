require 'rails_helper'

RSpec.describe 'Queries API' do

  describe 'POST /v1/queries' do

    it 'creates queries from JSON POST body' do
      sign_in Fabricate(:user)
      post ti_sqlegalize.queries_path,
        params: { queries: { sql: 'select * from t' } }.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        }
      expect(response).to have_http_status(201)
    end

  end

end
