class Api::V1::TokensController < Api::V1::ApplicationController

  deserializable_resource :token, only: [:create]

  before_action :allow_params_authentication!

  before_action :authenticate_user!

  before_action(only: %i[destroy show]) do
    @token = current_user.tokens.find(params[:id])
  end

  def create
    token = current_user.tokens.create(params.key?(:token) ? params.require(:token).permit(:comment) : params.permit)
    token.reset
    token.save!
    response.set_header('Authorization', "Token #{token.token}")
    render jsonapi: token, status: :created
  end

  def index
    render jsonapi: current_user.tokens
  end

  def show
    render jsonapi: @token
  end

  def destroy
    @token.destroy
    render jsonapi: nil
  end

end
