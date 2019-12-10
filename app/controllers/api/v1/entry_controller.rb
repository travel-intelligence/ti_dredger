class Api::V1::EntryController < Api::V1::ApplicationController

  def index
    rep = {
      api: {
        href: api_v1_entry_url,
        links: {
          tokens: api_v1_tokens_url,
          rel_json: api_v2_entry_url
        },
        version: 1
      }
    }
    render_api json: rep
  end

end
