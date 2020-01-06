require 'cfhighlander.publisher'
require 'cfhighlander.factory'
require 'cfhighlander.validator'

require 'cfnbackup/version'

module CfnBackup
  class CfHighlander

    def initialize(region, name, config, output_dir)
      @component_name = name
      @region = region
      @config = config
      @cfn_output_format = 'yaml'
      @output_dir = output_dir
      ENV['CFHIGHLANDER_WORKDIR'] = output_dir
    end

    def render()
      component = load_component(@component_name)
      Log.logger.debug("Compiling component, saving generated templates to #{@output_dir}")
      compiled = compile_component(component)
      validate_component(component,compiled.cfn_template_paths)
      cfn_template_paths = compiled.cfn_template_paths
      return compiled
    end

    def publish(cf_compiler)
      publisher = Cfhighlander::Publisher::ComponentPublisher.new(cf_compiler.component, false, @cfn_output_format)
      Log.logger.debug("Publishing compiled templates to S3")
      publisher.publishFiles(cf_compiler.cfn_template_paths)
      Log.logger.debug("Master template URL: #{publisher.getTemplateUrl}")
      return publisher.getTemplateUrl
    end

    private

    def load_component(component_name)
      factory = Cfhighlander::Factory::ComponentFactory.new
      component = factory.loadComponentFromTemplate(component_name)
      component.config = @config
      component.version = CfnBackup::VERSION
      component.load()
      return component
    end

    def compile_component(component)
      component_compiler = Cfhighlander::Compiler::ComponentCompiler.new(component)
      component_compiler.compileCloudFormation(@cfn_output_format)
      return component_compiler
    end

    def validate_component(component,template_paths)
      component_validator = Cfhighlander::Cloudformation::Validator.new(component)
      component_validator.validate(template_paths, @cfn_output_format)
    end

  end
end
