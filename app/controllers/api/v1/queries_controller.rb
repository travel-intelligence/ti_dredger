class Api::V1::QueriesController < ApplicationController
  def create
    query = params[:query].presence
    
    return render_api json: { 'error': 'missing query' }, status: 400 unless query

    query = query.to_s

    ast = SQLiterate::QueryParser.new.parse query

    return render_api json: { 'error': 'invalid query' }, status: 400 unless ast

    id = SecureRandom.hex(16)
    href = api_v1_query_url(id)
    rep = {
      queries: {
        id: id,
        href: href,
        sql: query,
        tables: ast.tables
      }
    }
    response.headers['Location'] = href
    render_api json: rep, status: 201
  end

  def show
    render_api json: {}, status: 204
  end
end
