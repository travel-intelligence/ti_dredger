require 'rails_helper'

# Mock the LDAP authentication strategy
module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable

      class << self
        attr_accessor :allowed_users
      end
      @allowed_users = []

      def authenticate!
        user_name = authentication_hash[:user_name]
        if Devise::Strategies::LdapAuthenticatable.allowed_users.include?(user_name)
          success! Fabricate(:user, user_name: user_name)
        else
          fail! "Unauthorized mocked LDAP user: #{user_name}"
        end
      end
    end
  end
end

RSpec.describe Api::V1::TokensController do

  context 'testing authentication' do

    before :each do
      Devise::Strategies::LdapAuthenticatable.allowed_users = []
    end

    it 'does not allow an anonymous user to check tokens' do
      get :index, format: :jsonapi
      expect(response.status).to eq(401)
    end

    it 'allows a user identified with LDAP name and pasword to check its tokens' do
      Devise::Strategies::LdapAuthenticatable.allowed_users = ['test_user']
      get :index, format: :jsonapi, params: { user: { user_name: 'test_user', password: 'test_password' } }
      expect(response.status).to eq(200)
    end

    it 'does not allow a user using a wrong token to check tokens' do
      request.headers.merge!('Authorization' => 'Token wrong_token')
      get :index, format: :jsonapi
      expect(response.status).to eq(401)
    end

    it 'does not allow a user using a wrong token to check tokens even if the user is authorized' do
      Devise::Strategies::LdapAuthenticatable.allowed_users = ['test_user']
      request.headers.merge!('Authorization' => 'Token wrong_token')
      get :index, format: :jsonapi, params: { user: { user_name: 'test_user', password: 'test_password' } }
      expect(response.status).to eq(401)
    end

    it 'allows a user identified with token correctly' do
      user = Fabricate(:user)
      token = user.tokens.create(comment: 'My token')
      token.reset
      token.save!
      request.headers.merge!('Authorization' => "Token #{token.token}")
      get :index, format: :jsonapi
      expect(response.status).to eq(200)
    end

  end

end
