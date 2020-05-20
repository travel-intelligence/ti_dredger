require 'rails_helper'

RSpec.describe User do

  let(:user) { Fabricate(:user, user_name: 'user_for_market') }
  let(:super_user) { Fabricate(:user, user_name: 'user_read_all') }

  it 'tells it can read a schema' do
    schema = TiSqlegalize::Schema.find 'MARKET'
    expect(user.can_read_schema?(schema)).to be true
  end

  it 'tells it cannot read a schema' do
    schema = TiSqlegalize::Schema.find 'HR'
    expect(user.can_read_schema?(schema)).to be false
  end
  
  it 'tells it can read all schemas' do
    schema1 = TiSqlegalize::Schema.find 'MARKET'
    expect(super_user.can_read_schema?(schema1)).to be true
    
    schema2 = TiSqlegalize::Schema.find 'HR'
    expect(super_user.can_read_schema?(schema2)).to be true
  end
end
