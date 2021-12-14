require "active_record"
require "yaml"
require "erb"
require_relative "../lib/event_store_logger"

# This is some boilerplate code to read the config/database.yml file
# And connect to the database
config_path = File.join(File.dirname(__FILE__), "database.yml")
ActiveRecord::Base.configurations = YAML.load(ERB.new(File.read(config_path)).result)
ActiveRecord::Tasks::DatabaseTasks.database_configuration = ActiveRecord::Base.configurations
ActiveRecord::Base.establish_connection(:development)

# Set a dedicated logger so that you can view the SQL actually performed by ActiveRecord
ActiveRecord::Base.logger = EventStoreLogger.create_logger

Dir["#{__dir__}/../app/models/*.rb"].each {|file| require file }
Dir["#{__dir__}/../app/projectors/*.rb"].each {|file| require file }

