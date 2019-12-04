# Warden strategy authenticating a user based on the Token given in the request
class ApiTokenStrategy < Warden::Strategies::Base

  # Get the API token from a request
  #
  # Parameters::
  # * *request* (Request): The request to get token from
  # Result::
  # * String: The API token, or nil if none
  def self.api_token(request)
    if request.headers.key?('Authorization')
      request.headers['Authorization'].remove('Token ')
    else
      nil
    end
  end

  # Is this strategy valid in our context?
  #
  # Result::
  # * Boolean: Is this strategy valid in our context?
  def valid?
    !::ApiTokenStrategy.api_token(request).nil?
  end

  # Authenticate the user
  def authenticate!
    token = Token.where('expires_at > ?', Time.now).find_by(token: ::ApiTokenStrategy.api_token(request))
    if token.nil?
      fail!('Invalid token')
    else
      success!(token.user)
    end
  end

end
