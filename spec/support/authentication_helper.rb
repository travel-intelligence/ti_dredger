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

module AuthenticationHelper

  # Define authentication specs for the given action
  #
  # Parameters::
  # * *action* (Symbol): Action on which authentication specs should be run
  def authentication_specs_on(action)

    context "testing authentication on #{action}" do

      before :each do
        Devise::Strategies::LdapAuthenticatable.allowed_users = []
      end

      it 'does not allow an anonymous user' do
        get action, format: :jsonapi
        expect(response.status).to eq(401)
      end

      it 'allows a user identified with LDAP name and pasword' do
        Devise::Strategies::LdapAuthenticatable.allowed_users = ['test_user']
        get action, format: :jsonapi, params: { user: { user_name: 'test_user', password: 'test_password' } }
        expect(response.status).to eq(200)
      end

      it 'does not allow a user using a wrong token' do
        request.headers['Authorization'] = 'Token wrong_token'
        get action, format: :jsonapi
        expect(response.status).to eq(401)
      end

      it 'does not allow a user using a wrong token even if the user is authorized' do
        Devise::Strategies::LdapAuthenticatable.allowed_users = ['test_user']
        request.headers['Authorization'] = 'Token wrong_token'
        get action, format: :jsonapi, params: { user: { user_name: 'test_user', password: 'test_password' } }
        expect(response.status).to eq(401)
      end

      it 'allows a user identified with token correctly' do
        user = Fabricate(:user)
        token = user.tokens.create(comment: 'My token')
        token.reset
        token.save!
        request.headers['Authorization'] = "Token #{token.token}"
        get action, format: :jsonapi
        expect(response.status).to eq(200)
      end

      it 'does not allow a user identified with an expired token' do
        user = Fabricate(:user)
        token = user.tokens.create(comment: 'My token')
        token.reset
        token.expires_at = Time.now - 1.day
        token.save!
        request.headers['Authorization'] = "Token #{token.token}"
        get action, format: :jsonapi
        expect(response.status).to eq(401)
      end

    end

  end

end

RSpec.configure do |c|
  c.extend AuthenticationHelper
end
