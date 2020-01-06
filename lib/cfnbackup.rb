require "thor"
require "cfnbackup/version"
require "cfnbackup/generate"
require "cfnbackup/publish"

module CfnBackup
  class Cli < Thor

    map %w[--version -v] => :__print_version
    desc "--version, -v", "Print the version"

    def __print_version
      puts CfnBackup::VERSION
    end

    register CfnBackup::Generate, 'generate', 'generate', 'Generates a CloudFormation template'
    tasks['generate'].options = CfnBackup::Generate.class_options

    register CfnBackup::Publish, 'publish', 'publish', 'Generates, validates and publishes the CloudFormation to S3' 
    tasks['publish'].options = CfnBackup::Publish.class_options

  end

end