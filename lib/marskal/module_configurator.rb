require 'marskal/module_configurator/version'

require 'active_support/concern'
require 'active_support/core_ext/module/attr_internal'
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/object'

require 'marskal/core_ext/all'   #TODO. Only grab whats needed? Array, Object?


module Marskal
  module ModuleConfigurator
      extend ActiveSupport::Concern
      attr_internal_accessor :established_defaults
      attr_internal_reader :added_dynamically

      included do
        @added_dynamically = []
      end

      module ClassMethods
        CONFIGURATION_CLASS_NAME = 'Configuration'
        attr_accessor :configuration

        def setup(p_attributes, p_options = {})
          p_options.assert_valid_keys(:set_defaults) unless p_options.empty?
          p_options.provide_default(:set_defaults, false)

          l_defaults = {}
          if p_attributes.is_a?(Hash)
            l_defaults = p_attributes
            p_attributes = l_defaults.keys
          else
            p_attributes.flatten!
          end

          unless configured?
            self.const_set(CONFIGURATION_CLASS_NAME, Class.new { def new()  end })
          end

          l_new_attributes = p_attributes.reject {|a| @configuration.instance_variable_defined?(:"@#{a.to_s}") || @added_dynamically.include?(a.to_s)}
          (@added_dynamically << l_new_attributes).flatten!.uniq

          self.configuration.add_attr_accessors(p_attributes)

          unless l_defaults.empty?
            configure do |config|
              l_defaults.each do |k,v|
                config.send("#{k}=", v)
              end
            end
            mcfg_set_defaults(l_defaults) if p_options[:set_defaults]
          end
          self.configuration
        end

        def configuration
          begin
            # @configuration ||= "#{self.name}::#{CONFIGURATION_CLASS_NAME}".classify.constantize.new
            @configuration ||= config_class.new
          rescue NameError => error
            unless self::const_defined?(CONFIGURATION_CLASS_NAME)
              raise "#{self} included Marskal::Configurator which requires a #{CONFIGURATION_CLASS_NAME} class to be defined. Refer to the gem 'marskal' docs. [#{error}]"
            else
              raise error
            end

          end
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

        def reset(p_options = {})
          p_options.provide_default(:remove_added_attributes, true)
          p_options.provide_default(:apply_defaults, true)

          # mcfg_attributes_added.each do |l_attr|
          #   config_class.send(:undef_method, l_attr.to_sym)
          # end
          if p_options[:remove_added_attributes]
            @configuration.remove_attr_accessors(mcfg_attributes_added)
            @established_defaults.except!(*@added_dynamically)
            @added_dynamically = []
          end
          @configuration = config_class.new
          if p_options[:apply_defaults]
            setup(@established_defaults)
          end
        end

        def deconfigure
          remove_const(CONFIGURATION_CLASS_NAME)
        end

        def mcfg_set_defaults(p_hash)
          #error if an undefined attr is sent
          @established_defaults ||= {}
          p_hash.each do |k,v|
            @established_defaults[k.to_sym] = v
          end
        end

        def mcfg_remove_selected_defaults(*attributes)
          z = @established_defaults.except!(*attributes)
          @established_defaults
        end

        def mcfg_remove_all_defaults
          @established_defaults = []
        end

        def mcfg_defaults
          @established_defaults
        end

        def mcfg_attributes_added
          @added_dynamically.uniq||[]
        end

        private

        def config_class
          self.const_get(CONFIGURATION_CLASS_NAME)
        end

      end
    end
end
