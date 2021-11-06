require "flu-rails"

module Flu
  class Event
    ## rails is not included
    class ActionDispatch
      class Http
        class UploadedFile
        end
      end
    end
  end
end

Flu.configure do |config|
  logger                            = Logger.new(STDOUT)
  logger.level                      = Logger::INFO
  config.development_environments   = []
  config.rabbitmq_host              = ENV["RABBITMQ_HOST"]
  config.rabbitmq_port              = ENV["RABBITMQ_PORT"]&.to_i
  config.rabbitmq_management_port   = ENV["RABBITMQ_MANAGEMENT_SCHEME"] || "http"
  config.rabbitmq_management_port   = ENV["RABBITMQ_MANAGEMENT_PORT"]&.to_i
  config.rabbitmq_user              = ENV["RABBITMQ_USER"]
  config.rabbitmq_password          = ENV["RABBITMQ_PASSWORD"]
  config.rabbitmq_exchange_name     = ENV["RABBITMQ_EXCHANGE_NAME"]
  config.rabbitmq_exchange_durable  = ENV["RABBITMQ_EXCHANGE_DURABLE"] == "true"
  config.auto_connect_to_exchange   = false
  config.logger                     = logger
end
