require 'thor'
require 'cfnbackup/log'

module CfnBackup
  class Utils
    include CfnBackup::Log

    def self.deep_merge(global, custom)
      custom.each do |k,v|
        Log.logger.debug("Checking global config for #{k}:#{v}")
        if global.key? k
          if global[k].class == Hash && custom[k].class == Hash
            Log.logger.debug("Key #{k} is a Hash present in both templates, running merge recursively")
            global[k] = deep_merge(global[k], v)
          else
            Log.logger.debug("Overriding defaults with key-value pair #{k}:#{v}")
            global[k] = v
          end
        else
          Log.logger.debug("Key-value pair #{k}:#{v} not found in original config, appending")
          global[k] = v
        end
      end
      return global
    end

  end
end

class Hash
  def without(*keys)
    dup.without!(*keys)
  end

  def without!(*keys)
    reject! { |key| keys.include?(key) }
  end
end