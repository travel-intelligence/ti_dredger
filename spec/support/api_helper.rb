# encoding: utf-8

module ApiHelper
  def post_api(action, options = {})
    post action, options.merge(format: :jsonapi)
  end
end

RSpec.configure do |c|
  c.include ApiHelper
end
