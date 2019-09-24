require 'rails_helper'

RSpec.describe 'RESTful API' do

  it 'is described by a profile' do
    get api_v1_entry_path, headers: { 'ACCEPT' => 'application/vnd.api+json' }
    expect(response).to have_http_status(200)
    expect(response.links.find { |l| l.params['rel'] == 'profile' }).not_to be_nil
  end
end
