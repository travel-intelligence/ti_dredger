# encoding: utf-8

module ApiHelper
  def first_json_at(path)
    JsonPath.on(response.body, path).first
  end

  def get_api(action, options = {})
    get action, options.merge(format: :jsonapi)
  end

  def post_api(action, options = {})
    post action, options.merge(format: :jsonapi)
  end
end

module ActionDispatch
  class TestResponse
    LinkHeader = Struct.new(:url, :params)

    def links
      if (h = headers['Link'])
        h.split("\n").map do |l|
          url, *params = l.split(';').map(&:strip)
          plist = params.map do |p|
            k, v = p.split('=', 2)
            [k, v[1..-2]]
          end.flatten
          LinkHeader.new(url[1..-2], Hash[*plist])
        end
      else
        []
      end
    end
  end
end

RSpec.configure do |c|
  c.include ApiHelper
end
