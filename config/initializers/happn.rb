require_relative "../../lib/event_store_logger"

def custom_projectors
  class_names = ENV["CUSTOM_PROJECTORS"] || ""
  class_names.split(",")
             .map(&:strip)
             .map { |class_name| Object.const_get(class_name) }
end

Happn.configure do |config|
  config.logger                     = EventStoreLogger.logger
  config.rabbitmq_host              = ENV["RABBITMQ_HOST"]
  config.rabbitmq_port              = ENV["RABBITMQ_PORT"]&.to_i
  config.rabbitmq_management_scheme = ENV["RABBITMQ_MANAGEMENT_SCHEME"]
  config.rabbitmq_management_port   = ENV["RABBITMQ_MANAGEMENT_PORT"]&.to_i
  config.rabbitmq_user              = ENV["RABBITMQ_USER"]
  config.rabbitmq_password          = ENV["RABBITMQ_PASSWORD"]
  config.rabbitmq_queue_name        = ENV["RABBITMQ_QUEUE_NAME"]
  config.rabbitmq_exchange_name     = ENV["RABBITMQ_EXCHANGE_NAME"]
  config.rabbitmq_exchange_durable  = ENV["RABBITMQ_EXCHANGE_DURABLE"] == "true"
  config.projector_classes          = [SaveAllEventsProjector] + custom_projectors
end
