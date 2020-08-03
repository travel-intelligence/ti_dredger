require 'rails_helper'

RSpec.describe 'Errors handler' do

  it 'catches routing errors' do
    get '/nothing'
    expect(response).to have_http_status(404)
  end
end
