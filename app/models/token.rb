require 'securerandom'

class Token < ActiveRecord::Base

  belongs_to :user

  # Reset the token, by assigning a new value and expiry date
  def reset
    self.token = SecureRandom.hex(64)
    self.expires_at = Time.now + 6.months
  end

end
