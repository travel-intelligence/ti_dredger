# Register the ApiTokenStrategy
Warden::Strategies.add(:api_token, ApiTokenStrategy)
Warden::Strategies.add(:auto_login, AutoLoginStrategy) if Rails.application.config.allow_autologin
