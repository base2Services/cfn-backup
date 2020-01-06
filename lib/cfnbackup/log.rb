require 'logger'

module CfnBackup
  module Log

    def self.colors
      @colors ||= {
        ERROR: 31, # Red
        WARN: 33, # Yellow
        DEBUG: 32, # Green
        INFO: 0
      }
    end

    def self.logger
      if @logger.nil?
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::INFO
        @logger.formatter = proc do |severity, datetime, progname, msg|
          "\e[#{colors[severity.to_sym]}m#{severity}: - #{msg}\e[0m\n"
        end
      end
      @logger
    end

    def self.logger=(logger)
      @logger = logger
    end

    levels = %w(debug info warn error fatal)
    levels.each do |level|
      define_method("#{level.to_sym}") do |msg|
        self.logger.send(level, msg)
      end
    end

  end
end
