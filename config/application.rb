require "active_record"
require "yaml"
require "erb"

# This is some boilerplate code to read the config/database.yml file
# And connect to the database
config_path = File.join(File.dirname(__FILE__), "database.yml")
ActiveRecord::Base.configurations = YAML.load(ERB.new(File.read(config_path)).result)
ActiveRecord::Tasks::DatabaseTasks.database_configuration = ActiveRecord::Base.configurations
ActiveRecord::Base.establish_connection(:development)

# Set a logger so that you can view the SQL actually performed by ActiveRecord
logger = Logger.new(STDOUT)
logger.formatter = proc do |severity, datetime, progname, msg|
   "#{msg}\n"
end
ActiveRecord::Base.logger = logger

Dir["#{__dir__}/../app/models/*.rb"].each {|file| require file }
Dir["#{__dir__}/../app/projectors/*.rb"].each {|file| require file }

