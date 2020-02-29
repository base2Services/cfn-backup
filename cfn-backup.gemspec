
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cfnbackup/version"

Gem::Specification.new do |spec|
  spec.name          = "cfn-backup"
  spec.version       = CfnBackup::VERSION
  spec.authors       = ["lohgannash"]
  spec.email         = ["lohgannash@gmail.com"]

  spec.summary       = %q{Generates templates and configuration for AWS Backup via CloudFormation}
  spec.description   = %q{Geneate templates and configuration for AWS Backup via CloudFormation}
  spec.homepage      = "https://github.com/base2services/cfn-backup"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/base2services/cfn-backup"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "components"]

  spec.add_dependency "thor", "~> 0.20"
  spec.add_dependency 'cfhighlander', '~> 0.10.3', '<1'
  spec.add_dependency 'cfndsl', '~> 0.17.2', '<1'

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
