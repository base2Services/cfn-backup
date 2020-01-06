require 'thor'
require 'fileutils'
require 'cfnbackup/log'
require 'cfnbackup/generate'
require 'cfnbackup/utils'
require 'cfnbackup/cfhighlander'

module CfnBackup
  class Publish < Thor::Group
    include Thor::Actions
    include Thor::Shell
    include CfnBackup::Log

    class_option :profile, aliases: :p, desc: 'AWS Profile'
    class_option :region, aliases: :r, default: ENV['AWS_REGION'], desc: 'AWS Region'
    class_option :verbose, desc: 'Enable DEBUG logging', type: :boolean

    class_option :config, desc: 'Provide a path to a config file to override defaults'
    class_option :stack_name, desc: 'Override the default stack name for the AWS Backup stack'
    class_option :source_bucket, desc: 'Source bucket to upload template files to'

    def self.source_root
      File.dirname(__FILE__)
    end

    def set_loglevel
      Log.logger.level = Logger::DEBUG if @options['verbose']
      Log.logger.debug("Log level set to DEBUG")
    end

    def set_stack_name
      if @options['stack_name']
        @stack_name = @options['stack_name']
        Log.logger.debug("Stack name provided, set to #{@stack_name}")
      else
        @stack_name = "cfnbackup"
        Log.logger.debug("Using default stack name #{@stack_name}")
      end
    end

    def set_source_bucket
      if !@options['source_bucket']
        Log.logger.debug("No source bucket provided")
        abort("Set source S3 bucket with --source-bucket flag")
      else
        Log.logger.debug("Setting source bucket to #{@options['source_bucket']}")
        @source_bucket = @options['source_bucket']
      end
    end

    def create_build_directory
      @build_dir = "output/#{@stack_name}"
      Log.logger.debug("Creating output directory #{@build_dir}")
      FileUtils.mkdir_p(@build_dir)
    end

    def initialize_config
      Log.logger.debug("Initialising config, loading global config file")
      global_config_path = File.join(File.dirname(__FILE__), '../config/global_config.yml')
      global_config = YAML.load(File.read(global_config_path))
      if @options['config']
        Log.logger.debug("Custom config file path provided, attempting to load")
        if File.file?(@options['config'])
          custom_config = YAML.load(File.read(@options['config']))
          Log.logger.debug("Custom config file loaded, deep merging with global config")
          @config = CfnBackup::Utils.deep_merge(global_config, custom_config)
        else
          abort("Could not find or load file #{@options['config']}")
        end
      else
        Log.logger.debug("No custom config file provided, using all default values")     
        @config = global_config
      end
      @config['stack_name'] = @stack_name
      @config['source_bucket'] = @source_bucket
    end

    def publish_cloudformation
      Log.logger.debug("Populating CfHighlander file from template")
      template('templates/cfnbackup.cfhighlander.rb.tt', "#{@build_dir}/#{@stack_name}.cfhighlander.rb", @config, force: true)
      Log.logger.debug("Generating CloudFormation template from #{@build_dir}/#{@stack_name}.cfhighlander.rb")
      cfhl = CfnBackup::CfHighlander.new(@options['region'], @stack_name, nil, @build_dir)
      compiler = cfhl.render()
      Log.logger.debug("CloudFormation template generated and validated")
      @template_url = cfhl.publish(compiler)
    end

  end
end