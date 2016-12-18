require 'marskal/module_configurator/version'

require 'active_support/concern'
require 'active_support/core_ext/module/attr_internal'
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/object'

require 'marskal/core_ext/array'

module Marskal
  module ModuleConfigurator
      extend ActiveSupport::Concern
      attr_internal_accessor :added_dynamically, :established_defaults

      #maybe make dynamic in the future
      CONFIGURATION_CLASS_NAME = 'Configuration'
      attr_accessor :configuration

      included do
        @added_dynamically = []
        private_class_method :config_class
      end

      module ClassMethods



        def setup(*attributes) #, p_options = {})
          # a = Marskal::ModuleConfigurator::config_class_name
          # b = xconfig_class_name
#          [:establish_defaults].assert_valid_keys(p_options)

          attributes.flatten!
          l_defaults = {}
          if attributes.length == 1 && attributes.first.is_a?(Hash)
            l_defaults = attributes.first
            attributes = l_defaults.keys
          end

          unless configured?
            self.const_set(CONFIGURATION_CLASS_NAME, Class.new { def new()  end })
          end

          qq = self.const_get(CONFIGURATION_CLASS_NAME)

          (@added_dynamically << attributes).flatten!.uniq

          attributes.each do |k|
            unless self.configuration.respond_to?("#{k.to_s}=")
              # self::Configuration.send(:define_method, "#{k}=".to_sym) do |value|
              # self.const_get(CONFIGURATION_CLASS_NAME).send(:define_method, "#{k}=".to_sym) do |value|
              config_class.send(:define_method, "#{k}=".to_sym) do |value|
                instance_variable_set("@" + k.to_s, value)
              end
            end
            unless self.configuration.respond_to?(k.to_s)
                # self::Configuration.send(:define_method, k.to_sym) do
              config_class.send(:define_method, k.to_sym) do
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
            # establish_defaults(l_defaults) if p_options[:established_defaults]
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

        def reset()
          attributes_added_dynamically.each do |l_attr|
            # self.class.to_s.constantize.send(:undef_method, l_attr.to_sym)
            # self::Configuration.send(:undef_method, l_attr.to_sym)
            config_class.send(:undef_method, l_attr.to_sym)
            # self.send(:undef_method, l_attr.to_sym)
            # self.class.send(:undef_method, l_attr.to_sym)
            # configuration.remove_instance_variable(:"@#{l_attr}")
          end
          @added_dynamically = []
          @established_defaults = nil
          # @configuration = self::Configuration.new   #TODO: remove hard coded name
          @configuration = config_class.new   #TODO: remove hard coded name
        end

        def configure
          yield(configuration)
        end

        def config_override(p_options= {})
          configuration.instance_values.merge(p_options).symbolize_keys
        end

        def configured?
          const_defined?(CONFIGURATION_CLASS_NAME)
        end

        def deconfigure
          remove_const(CONFIGURATION_CLASS_NAME)
        end

        def establish_defaults(p_hash)
          @defaults ||= {}
          p_hash.each do |k,v|
            @established_defaults[k.to_sym] = v
          end
        end

        def defaults
          @established_defaults
        end

        def attributes_added_dynamically
          @added_dynamically.uniq||[]
        end

        private

        def config_class
          self.const_get(CONFIGURATION_CLASS_NAME)
        end

      end
    end
end
