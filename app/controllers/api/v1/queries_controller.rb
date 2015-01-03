class Api::V1::QueriesController < ApplicationController
  def create
    render json: {}, status: 201
  end
end
