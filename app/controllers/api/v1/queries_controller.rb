class Api::V1::QueriesController < ApplicationController
  def create
    query = params[:query].presence
    if query
      id = SecureRandom.hex(16)
      href = api_v1_query_url(id)
      rep = {
        queries: {
          id: id,
          href: href,
          sql: query.to_s
        }
      }
      response.headers['Location'] = href
      render_api json: rep, status: 201
    else
      render_api json: {}, status: 400
    end
  end

  def show
    render_api json: {}, status: 204
  end
end
