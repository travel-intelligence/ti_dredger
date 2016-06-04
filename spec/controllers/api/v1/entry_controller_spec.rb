require 'rails_helper'

RSpec.describe Api::V1::EntryController, :type => :controller do

  include TiSqlegalize::Engine.routes.url_helpers

  it "responds with entry representation" do
    get_api :index
    expect(response.status).to eq(200)
    expect(first_json_at '$.api.version').to eq(1)
    expect(first_json_at '$.api.href').to eq(api_v1_entry_url)
    expect(first_json_at '$.api.links.r_new_query').to \
      eq(queries_url(host: 'test.host'))
  end
end
