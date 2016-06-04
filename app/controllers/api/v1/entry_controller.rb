class Api::V1::EntryController < ApplicationController
  def index
    rep = {
      api: {
        href: api_v1_entry_url,
        links: {
          r_new_query: ti_sqlegalize.queries_url
        },
        version: 1
      }
    }
    render_api json: rep
  end
end
