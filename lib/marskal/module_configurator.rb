require "marskal/module_configurator/version"
require 'active_support/concern'

module Marskal
  module ModuleConfigurator
      extend ActiveSupport::Concern
      module ClassMethods
        CONFIGURATION_CLASS_NAME = 'Configuration'
        attr_accessor :configuration

        def setup(*attributes)
          l_defaults = {}
          if attributes.length == 1 && attributes.first.is_a?(Hash)
            l_defaults = attributes.first
            attributes = l_defaults.keys
          end

          unless self::const_defined?(CONFIGURATION_CLASS_NAME)
            self.const_set(CONFIGURATION_CLASS_NAME, Class.new { def new()  end })
          end

          attributes.each do |k|
            unless self.configuration.respond_to?("#{k.to_s}=")
              self::Configuration.send(:define_method, "#{k}=".to_sym) do |value|
                instance_variable_set("@" + k.to_s, value)
              end
            end
            unless self.configuration.respond_to?(k.to_s)
                self::Configuration.send(:define_method, k.to_sym) do
                  instance_variable_get("@" + k.to_s)
                end
              end
          end

          unless l_defaults.empty?
            configure do |config|
              l_defaults.each do |k,v|
                config.send("#{k}=", v)
              end
            end
          end
          self.configuration
        end

        def configuration
          begin
            @configuration ||= "#{self.name}::#{CONFIGURATION_CLASS_NAME}".classify.constantize.new
          rescue NameError => error
            unless self::const_defined?(CONFIGURATION_CLASS_NAME)
              raise "#{self} included Marskal::Configurator which requires a #{CONFIGURATION_CLASS_NAME} class to be defined. Refer to the gem 'marskal' docs. [#{error}]"
            else
              raise error
            end

          end
        end

        def reset
          @configuration = self::Configuration.new
        end

        def configure
          yield(configuration)
        end

        def config_override(p_options= {})
          configuration.instance_values.merge(p_options).symbolize_keys
        end

        end

    end
end
