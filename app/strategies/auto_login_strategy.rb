# Warden strategy authenticating a user based on its user name given as a parameter in the request headers.
# Meant to be used only for debugging, development or testing purposes. Never in production.
class AutoLoginStrategy < Warden::Strategies::Base

  class << self

    # List of authorized user names
    # Array<String>
    attr_accessor :authorized_users

    # Get the user name from a request
    #
    # Parameters::
    # * *request* (Request): The request to get token from
    # Result::
    # * String: The user name, or nil if none
    def dev_user_name(request)
      if request.headers.key?('DevUserName')
        request.headers['DevUserName']
      else
        nil
      end
    end

  end
  @authorized_users = []

  # Is this strategy valid in our context?
  #
  # Result::
  # * Boolean: Is this strategy valid in our context?
  def valid?
    !Rails.env.production? && !::AutoLoginStrategy.dev_user_name(request).nil?
  end

  # Authenticate the user
  def authenticate!
    user = ::AutoLoginStrategy.dev_user_name(request)
    if !Rails.env.production? && ::AutoLoginStrategy.authorized_users.include?(user)
      success!(User.find_by_user_name(user))
    else
      fail!('Non authorized dev user name')
    end
  end

end
