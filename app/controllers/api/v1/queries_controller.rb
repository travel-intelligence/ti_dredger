class Api::V1::QueriesController < ApplicationController
  def create
    if params[:query].presence
      render_api json: {}, status: 201
    else
      render_api json: {}, status: 400
    end
  end
end
