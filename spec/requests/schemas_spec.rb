require 'rails_helper'

RSpec.describe "Schemas API", :type => :request do

  let(:user) { Fabricate(:user) }

  let(:admin) { user.admin }

  let(:auth_headers) do
    { 'From' => user.email,
      'X-Grants' => Base64.encode64({ grants: [
          { user: user.email,
            admin: admin,
            controls: [
              [ User::RELATIONAL_SCHEMA_CONTROL, true, { schemas: schemas } ]
            ] }
        ] }.to_json) }
  end

  describe "GET /v2/schemas" do

    context "with a market user" do

      let(:schemas) { ['MARKET'] }

      it "only fetches the index representation of the MARKET schema" do
        headers = { 'Accept' => 'application/json' }
        get ti_sqlegalize.v2_schemas_path, '', auth_headers.merge(headers)
        expect(response).to have_http_status(200)
        data = first_json_at '$.data'
        expect(data.length).to eq(1)
        expect(JsonPath.on(data.first, 'type').first).to eq('schema')
        expect(JsonPath.on(data.first, 'id').first).to eq('MARKET')
      end
    end

    context "with a hr user" do

      let(:schemas) { ['HR'] }

      it "only fetches the index representation of the HR schema" do
        headers = { 'Accept' => 'application/json' }
        get ti_sqlegalize.v2_schemas_path, '', auth_headers.merge(headers)
        expect(response).to have_http_status(200)
        data = first_json_at '$.data'
        expect(data.length).to eq(1)
        expect(JsonPath.on(data.first, 'type').first).to eq('schema')
        expect(JsonPath.on(data.first, 'id').first).to eq('HR')
      end
    end

    context "with an admin user" do

      let(:schemas) { [] }
      let(:admin) { true }

      it "fetches the index representation of all schemas" do
        pending("Admin flag not supported by the auth module.")
        headers = { 'Accept' => 'application/json' }
        get ti_sqlegalize.v2_schemas_path, '', auth_headers.merge(headers)
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
