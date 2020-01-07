require 'thor'
require 'cfnbackup/log'

module CfnBackup
  class Utils
    include CfnBackup::Log

    def self.deep_merge(global, custom)
      # Iterate through each key in the custom yaml file
      custom.each do |k,v|
        Log.logger.debug("Checking global config for #{k}:#{v}")
        # Check if the key exists in the global config
        if global.key? k
          # Check if the current key is a hash
          if global[k].class == Hash && custom[k].class == Hash
            # If it is, we will need to run the deep merge on this again to account for nested config
            Log.logger.debug("Key #{k} is a Hash present in both templates, running merge recursively")
            global[k] = deep_merge(global[k], v)
          else
            # Once (if any) recursion is complete, override the global value for the current key with the custom value
            Log.logger.debug("Overriding defaults with key-value pair #{k}:#{v}")
            global[k] = v
          end
        else
          # If it doesn't exist in the global config, merge it in
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