require 'rails_helper'

RSpec.describe User, :type => :model do

  let(:user) { Fabricate(:user_market) }

  it "accepts controls from the authentication module" do
    expect do
      user.controls = [["some_access_control", true, {}]]
    end.not_to raise_error
  end

  it "tells it can read a schema" do
    schema = TiSqlegalize::Schema.find 'MARKET'
    expect(user.can_read_schema?(schema)).to be true
  end

  it "tells it cannot read a schema" do
    schema = TiSqlegalize::Schema.find 'HR'
    expect(user.can_read_schema?(schema)).to be false
  end
end
