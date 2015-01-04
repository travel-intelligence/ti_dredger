require 'rails_helper'

RSpec.describe Api::V1::EntryController, :type => :controller do

  it "responds with entry representation" do
    get_api :index
    expect(response.status).to eq(200)
    expect(first_json_at '$.api.version').to eq(1)
    expect(first_json_at '$.api.href').to eq(api_v1_url)
    expect(first_json_at '$.api.links.r_new_query').to eq(api_v1_queries_url)
  end
end
