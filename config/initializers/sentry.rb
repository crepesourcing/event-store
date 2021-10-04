require "sentry-ruby"
if !Rails.env == "development" and !Rails.env == "test" and ENV.has_key?("SENTRY_DSN")
  Sentry.init do |config|
    config.dsn                  = ENV["SENTRY_DSN"]
    config.enabled_environments = %w[ qa staging production ]
    config.send_default_pii     = true
  end
end
