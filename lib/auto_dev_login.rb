# Rack middleware to automatically login dev user account.
# NEVER USE THIS MIDDLEWARE IN PRODUCTION
class AutoDevLogin

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
