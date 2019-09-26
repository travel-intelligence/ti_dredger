require 'rails_helper'

RSpec.describe Api::V1::TokensController do

  context 'testing index action' do

    before :each do
      @user = Fabricate :user
      sign_in @user
    end

    # Get index and set the data as a JSON object in @data
    def get_index
      get :index, format: :jsonapi
      expect(response.status).to eq(200)
      @data = JSON.parse(response.body)['data']
    end

    it 'responds with an empty list of tokens for a new user' do
      get_index
      expect(@data).to eq([])
    end

    it 'responds with the correct list of tokens and their attributes and links' do
      5.times do |idx|
        token = @user.tokens.create(comment: "Token ##{idx}")
        token.reset
        token.save!
      end
      get_index
      expect(@data.size).to eq(5)
      @user.tokens.each do |expected_token|
        found_token = @data.find { |token| token['id'].to_i == expected_token.id }
        expect(found_token).not_to be_nil
        expect(found_token).to have_attribute(:comment).with_value expected_token.comment
        expect(found_token).to have_attribute(:token).with_value expected_token.token
        expect(found_token).to have_attribute(:expires_at).with_value expected_token.expires_at.strftime('%FT%T.%LZ')
        # TODO: Understand why the following doesn't work and use it when corrected
        # expect(found_token).to have_link(:self).with_value api_v1_token_url(expected_token)
        expect(found_token).to have_link(:self)
        expect(found_token['links']['self']).to eq api_v1_token_url(expected_token)
        expect(found_token).to have_link(:delete)
        expect(found_token['links']['delete']).to eq api_v1_token_url(expected_token)
      end
    end

    it 'does not return tokens of another user' do
      other_user = Fabricate :user, user_name: 'other_user'
      5.times do |idx|
        token = other_user.tokens.create(comment: "Token ##{idx}")
        token.reset
        token.save!
      end
      get_index
      expect(@data).to eq([])
    end

  end

  context 'testing create action' do

    before :each do
      @user = Fabricate :user
      sign_in @user
    end

    # Post create with a given JSON payload
    #
    # Parameters::
    # * *payload* (Object): JSON payload, or nil if none [default = nil]
    def post_create(payload = nil)
      post :create, format: :jsonapi, params: payload
      expect(response.status).to eq(201)
      @data = JSON.parse(response.body)['data']
    end

    it 'creates a token' do
      post_create
      token = @user.tokens.first
      expect(token).not_to be_nil
      expect(@data).to have_attribute(:token)
      expect(@data['attributes']['token']).not_to be_nil
      expect(@data).to have_attribute(:expires_at)
      expect(@data).to have_link(:self)
      expect(@data['links']['self']).to eq api_v1_token_url(token)
      expect(@data).to have_link(:delete)
      expect(@data['links']['delete']).to eq api_v1_token_url(token)
    end

    it 'creates a token with comment' do
      post_create(token: { comment: 'My token' })
      expect(@data).to have_attribute(:comment).with_value 'My token'
    end

    it 'returns the token authorization in the headers' do
      post_create
      expect(response.headers).to have_key 'Authorization'
      expect(response.headers['Authorization']).to eq "Token #{@data['attributes']['token']}"
    end

  end

  context 'testing show action' do

    before :each do
      @user = Fabricate :user
      sign_in @user
    end

    # Get show a given token id and get the data
    #
    # Parameters::
    # * *token_id* (Integer): The token ID
    def get_show(token_id)
      get :show, format: :jsonapi, params: { id: token_id }
      expect(response.status).to eq(200)
      @data = JSON.parse(response.body)['data']
    end

    it 'shows a token' do
      token = @user.tokens.create(comment: 'My token')
      token.reset
      token.save!
      get_show token.id
      expect(@data).to have_attribute(:token)
      expect(@data['attributes']['token']).not_to be_nil
      expect(@data).to have_attribute(:expires_at)
      expect(@data).to have_attribute(:comment).with_value 'My token'
      expect(@data).to have_link(:self)
      expect(@data['links']['self']).to eq api_v1_token_url(token)
      expect(@data).to have_link(:delete)
      expect(@data['links']['delete']).to eq api_v1_token_url(token)
    end

    it 'fails in showing a missing token' do
      get :show, format: :jsonapi, params: { id: 666 }
      expect(response.status).to eq(404)
    end

    it 'fails in showing a token belonging to another user' do
      token = Fabricate(:user, user_name: 'other_user').tokens.create
      token.reset
      token.save!
      get :show, format: :jsonapi, params: { id: token.id }
      expect(response.status).to eq(404)
    end

  end

  context 'testing delete action' do

    before :each do
      @user = Fabricate :user
      sign_in @user
    end

    # Delete destroy a given token id and get the data
    #
    # Parameters::
    # * *token_id* (Integer): The token ID
    def delete_destroy(token_id)
      delete :destroy, format: :jsonapi, params: { id: token_id }
      expect(response.status).to eq(200)
      @data = JSON.parse(response.body)['data']
    end

    it 'deletes a token' do
      token = @user.tokens.create(comment: 'My token')
      token.reset
      token.save!
      delete_destroy token.id
      token = @user.tokens.first
      expect(token).to be_nil
      expect(@data).to be_nil
    end

    it 'fails to delete a missing token' do
      delete :destroy, format: :jsonapi, params: { id: 666 }
      expect(response.status).to eq(404)
    end

    it 'fails to delete a token belonging to another user' do
      other_user = Fabricate(:user, user_name: 'other_user')
      token = other_user.tokens.create(comment: 'My token')
      token.reset
      token.save!
      delete :destroy, format: :jsonapi, params: { id: token.id }
      expect(response.status).to eq(404)
      other_token = other_user.tokens.first
      expect(other_token).not_to be_nil
      expect(other_token.comment).to eq 'My token'
    end

  end

end
