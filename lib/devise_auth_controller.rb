# Authentication controller interface used by TiSqlegalize, and implementing devise authentication
module DeviseAuthController

  # Return the current user
  #
  # Result::
  # * User: The current user
  def current_user
    # Call the one from Devise
    super
  end

  # Authenticate the user
  #
  # Result::
  # * Boolean: Is the user authenticated?
  def authenticate
    authenticate_user!
    user_signed_in?
  end

end
