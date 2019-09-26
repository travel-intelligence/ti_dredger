require 'rails_helper'

RSpec.describe Token do

  it 'resets itself with a new token' do
    token = Token.new
    old_token = token.token
    token.reset
    expect(token.token).not_to eq nil
    expect(token.token).not_to eq old_token
  end

  it 'resets itself with a new expiration date' do
    token = Token.new
    token.reset
    expect(token.expires_at).to be >= (Time.now + 6.months) - 1.minute
  end

end
