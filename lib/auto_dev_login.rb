# Rack middleware to automatically login dev user account.
# NEVER USE THIS MIDDLEWARE IN PRODUCTION
class AutoDevLogin

  # Controller implementing authentication API always returning an authenticated user having all rights
  module AuthController
    def current_user
      User.new(admin: true)
    end

    def authenticate
      true
    end
  end

  def initialize(app)
    @app = app
    Rails.logger.info '!!! Automatically setup account dev_account. DO NOT USE THAT IN PRODUCTION.'
    puts
    puts '===== Automatically setup account dev_account. DO NOT USE THAT IN PRODUCTION. ====='
    puts
  end

  def call(env)
    Rails.logger.info '!!! Automatically setup account dev_account. DO NOT USE THAT IN PRODUCTION.'
    @app.call(env.merge({
      'HTTP_FROM' => 'dev_user@dev_mail.com',
      'HTTP_X_GRANTS' => Base64.encode64(ActiveSupport::JSON.encode({
        'grants' => [{
          'controls' => [
            [User::RELATIONAL_SCHEMA_CONTROL, true, { 'schemas' => ['MARKET'] }]
          ]
        }]
      }))
    }))
  end

end
