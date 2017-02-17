require "raven"
if !Rails.env == "development" and !Rails.env == "test" and ENV.has_key?("SENTRY_DSN")
  Raven.configure do |config|
    config.dsn          = ENV["SENTRY_DSN"]
    config.environments = %w[ staging production ]
  end
end
