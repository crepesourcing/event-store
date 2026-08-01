class Rails
  def self.application
    config = OpenStruct.new(paths: { "db" => []})
    application = OpenStruct.new({config: config, paths: {"db/migrate" => ["db/migrate", "db/custom"]}})
  end

  def self.root
    File.join(File.dirname(__FILE__), "..")
  end

  def self.env
    require "active_support/string_inquirer"
    ActiveSupport::StringInquirer.new(ENV["RAILS_ENV"] || "development")
  end

  def self.version
    "8"
  end

  class Railtie
    def self.railtie_name(name)
      name
    end

    def self.config
      Config.new
    end

    class Config
      def to_prepare(&block)
      end
      def after_initialize(&block)
      end
    end
  end
end
