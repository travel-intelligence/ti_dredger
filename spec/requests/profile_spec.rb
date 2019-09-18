require 'rails_helper'

RSpec.describe "RESTful API", :type => :request do

  it "is described by a profile" do
    headers = { 'ACCEPT' => 'application/vnd.api+json' }
    get api_v1_entry_path, headers: headers
    expect(response).to have_http_status(200)
    profile_link = response.links.find { |l| l.params['rel'] == 'profile' }
    expect(profile_link).not_to be_nil
  end
end
