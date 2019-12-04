require 'rails_helper'

RSpec.describe User do

  let(:user) { Fabricate(:user, user_name: 'user_for_market') }

  it 'tells it can read a schema' do
    schema = TiSqlegalize::Schema.find 'MARKET'
    expect(user.can_read_schema?(schema)).to be true
  end

  it 'tells it cannot read a schema' do
    schema = TiSqlegalize::Schema.find 'HR'
    expect(user.can_read_schema?(schema)).to be false
  end
end
