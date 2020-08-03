require 'rails_helper'

RSpec.describe 'Schemas API' do

  describe 'GET /v2/schemas' do

    context 'with a market user' do

      it 'only fetches the index representation of the MARKET schema' do
        sign_in Fabricate(:user, email: 'user_for_market@mail.com')
        get ti_sqlegalize.v2_schemas_path, headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(200)
        data = first_json_at '$.data'
        expect(data.length).to eq(1)
        expect(JsonPath.on(data.first, 'type').first).to eq('schema')
        expect(JsonPath.on(data.first, 'id').first).to eq('MARKET')
      end
    end

    context 'with a hr user' do

      it 'only fetches the index representation of the HR schema' do
        sign_in Fabricate(:user, email: 'user_for_hr@mail.com')
        get ti_sqlegalize.v2_schemas_path, headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(200)
        data = first_json_at '$.data'
        expect(data.length).to eq(1)
        expect(JsonPath.on(data.first, 'type').first).to eq('schema')
        expect(JsonPath.on(data.first, 'id').first).to eq('HR')
      end
    end

    context 'with an admin user' do

      it 'fetches the index representation of all schemas' do
        sign_in Fabricate(:user, admin: true)
        get ti_sqlegalize.v2_schemas_path, headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(200)
        data = first_json_at '$.data'
        expect(data.length).to eq(2)
        expect(JsonPath.on(data.first, 'type').first).to eq('schema')
        expect(JsonPath.on(data.first, 'id').first).to eq('MARKET')
        expect(JsonPath.on(data.last, 'type').first).to eq('schema')
        expect(JsonPath.on(data.last, 'id').first).to eq('HR')
      end
    end
  end
end
