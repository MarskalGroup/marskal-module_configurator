require 'marskal/module_configurator/version'

require 'active_support/concern'
require 'active_support/core_ext/module/attr_internal'
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/object'

require 'marskal/core_ext/all'   #TODO. Only grab whats needed? Array, Object?


module Marskal

  ##
  # This module is designed to aloow you to add a configuration to any model. This configuration can be
  # either static and fixed or totally dynamic or a combination of both. Refer to thjese examples for different
  # ways this gem can be used.
  #
  # ==== History
  # * <tt>Created: 2013-ish</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
  #
  # === Special Note
  # The default configuration class is +Configuration+. It is recommended to use that. However, it can be
  # changed using the method +mcfg_change_configuration_class+. This generally would be done to avoid naming
  # conflicts that may exist.
  #
  # ==== Usage
  #   #add this to the beginning of your module and then refer to the example modules
  #   include Marskal::ModuleConfigurator       #this will provide access to the ModuleConfigurator methods
  #
  # ==== Examples
  # *See the examples directory for these modules **
  # DiceMethodOne::         This demonstrates the simplest method where everything is static and the Configuration class
  # DiceMethodTwo::         This demonstrates the combining static and dynamic building of the configuration
  # DiceMethodThree::       This demonstrates a completely dynamic building of the the configuration
  # DiceMethodFour::        This Is basically MethodTwo, but with a custom configuration class I named +MyConfiguration+
  # DefaultsExperiments::   This Is basically MethodTwo, but with a custom configuration class I named +MyConfiguration+
  #
  module ModuleConfigurator
    extend ActiveSupport::Concern   #this is needed to process the calling module's +include+ statement
                                    #See http://api.rubyonrails.org/classes/ActiveSupport/Concern.html

      # This is the Default name of the class that must exist. It can be created by the calling program or +mcfg_setup+
      # method. It can be changed using the method +mcfg_change_configuration_class+.
      DEFAULT_CONFIGURATION_CLASS_NAME = 'Configuration'

      # This stores the configured class name. It defaults to the Constant +DEFAULT_CONFIGURATION_CLASS_NAME+
      # It can be changed using the method +mcfg_change_configuration_class+.
      attr_internal_reader :config_class_name

      # This is used to store dynamically added attributes(settings) of your configuration. This is internal and
      # and handled by this module. You can view the contents accessing the +mcfg_attributes_added+
      attr_internal_reader :added_dynamically

      # This is used to store defaults for BOTH predefined attributes and dynamically created attributes.
      # You can use parameters and calls to the following methods to manipulate and access this variable
      # * +mcfg_setup+
      # * +mcfg_reset+
      # * +mcfg_set_defaults+
      # * +mcfg_remove_selected_defaults+
      # * +mcfg_remove_all_defaults+
      # * +mcfg_defaults+
      attr_internal_reader :established_defaults


      ##
      # This gets run immediately when ruby loads via the +include+ directive
      included do
        @added_dynamically = []                                             #initialize these arrays
        @established_defaults = {}
        # @config_class_name = DEFAULT_CONFIGURATION_CLASS_NAME               #set default
        mcfg_change_configuration_class(DEFAULT_CONFIGURATION_CLASS_NAME)   #set default clas name
      end

      ##
      # This module has to be named exactly this. In this module all of the class methods that will be made available
      # to the the calling module.
      # See http://api.rubyonrails.org/classes/ActiveSupport/Concern.html for more information
      module ClassMethods

        # This is how the calling module (module with the include statement) will access the configuration.
        # Examples: @mcfg_config or MyCallingModule.mcfg_config
        attr_accessor :mcfg_config

        ##
        # This is how the calling module can access this configuration.
        #
        # ==== History
        # * <tt>Created: 2016-12-15</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
        #
        # ==== Returns
        # * <tt>(class Configuration)</tt>
        #   * Note That this class can be changed, but by default it is +class Configuration+
        #
        # ==== Examples
        #
        #   module MyModule
        #     include Marskal::ModuleConfigurator
        #
        #     class Configuration
        #       attr_accessor :myvar1, :myvar2
        #
        #       def initialize
        #         @myvar1 = 1
        #         @myvar1 = "Two"
        #       end
        #     end
        #
        #     def self.example_usage_in_a_method
        #       myconfig = mcfg_config
        #       myconfig = @mcfg_config
        #       myconfig = self.mcfg_config
        #     end
        #   end
        #
        #   # Given the Example module/class above here are some examples
        #   # First notice how it can be used within a class method
        #   # Three different methods to access as shown below
        #   def self.example_usage_in_a_method
        #       myconfig = mcfg_config
        #       myconfig = @mcfg_config
        #       myconfig = self.mcfg_config
        #   end
        #
        #   # From outside the module you can simply do this
        #   MyModule.mcfg_config
        #
        #   # You can also create a new configuration to manipulate, however it wont be used until use assign it back
        #   # Here we create a new instance
        #   c = MyMod::Configuration.new        # Lets instantiate a new class
        #   c.myvar1 = 99                       # Lets change its settings
        #   c.myvar2 = "Hello World"
        #   puts c                              # Now we can see out changes
        #
        #   puts MyMod.mcfg_config              # The changes are not reflected
        #   MyMod.mcfg_config = c               # Now the new changes have been applied
        #                                       # There are many ways to change the settings, review documentation and
        #                                       # examples carefully for a more complete understanding
        # ---
        def mcfg_config
          begin
            @mcfg_config ||= config_class.new     # if we dont have our config yet, we will create it
          rescue NameError => error               # if we get an error then our Configuration class is not yet defined
            unless self::const_defined?(@config_class_name)   #generate an error, to help the programmer
              raise "#{self} included Marskal::Configurator which requires a #{@config_class_name} class to be defined. Refer to the gem 'marskal' docs. [#{error}]"
            else
              raise error   #some other error
            end

          end
        end

        ##
        # This module is pretty flexible and powerful. Ir provides functionality to:
        # * Create the Configuration class dynamically
        # * Add dynamic attributes/settings
        # * Set defaults for both pre-exsiting and dynamic settings
        # * Store the defaults for later uses during a mcfg_reset
        #
        # ==== History
        # * <tt>Created: 2016-12-15</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
        #
        # ==== Params
        # * <tt>p_attributes(Array of Attributes or a Hash of settings and values):</tt>
        #   This format will contain the names of the attributes/settings to add
        #   * If an +Array+, then this wil be a list of attribute names only (ex: [:fld1, :fld2])
        #   * If a +Hash+,  it will have values as well { fld1: "Foo", fld2: "bar"}
        #
        # * <tt>p_options(Hash)(_defaults_ to: {} ):</tt> The various settings to guide the setup process
        #   * <tt>:set_defaults(Boolean) (_defaults_ to: false ):</tt>  If true, any values passed via the hash will
        #   be stored as defaults to be using when a +mcfg_reset+ is called
        #
        # ==== Returns
        # * <tt>(class Configuration)</tt>
        #   * Note That this class can be changed, but by default it is +class Configuration+
        #
        # ==== Examples
        #   # This line will add these attributes to config, but not set the values as defaults
        #   MyMod.mcfg_setup({color: 'Green', size: 'Small'})
        #
        #   # This line will add these attributes to config, AND ALSO not set the values as defaults
        #   MyMod.mcfg_setup({color: 'White', size: 'Large'}, set_defaults: true)
        #
        #   # This line will add these attributes to config and assign no values, but now they can be accessed
        #   MyMod.mcfg_setup([:color, :size]})
        #
        # ---
        def mcfg_setup(p_attributes, p_options = {})
          p_options.assert_valid_keys(:set_defaults) unless p_options.empty?  #only allow valid keys
          p_options.provide_default(:set_defaults, false)                     #setting to determine storage of defaults

          l_defaults = {}                   #init hash
          if p_attributes.is_a?(Hash)       #if a Hash was passed
            l_defaults = p_attributes       #lets store the defaults
            p_attributes = l_defaults.keys  #then lets extract the key names
          else
            p_attributes.flatten!           #otherwise, lets just make sure we have a flat array od names
          end

          # Check to see if the Configuration class (or whatever class is being used) hass been created.
          # If not, then we can create it here
          unless mcfg_configured?
            self.const_set(@config_class_name, Class.new { def new()  end })
          end

          # Lets add any new attributes to our list. Reject anything that has been already defined
          # dynamically or statically
          l_new_attributes = p_attributes.reject {|a|  mcfg_config.instance_variable_defined?(:"@#{a.to_s}") || @added_dynamically.include?(a.to_s)}

          (@added_dynamically << l_new_attributes).flatten!.uniq  # Now add to the existing array of added settings
          @mcfg_config.add_attr_accessors(p_attributes)           # now lets add them to our class

          unless l_defaults.empty?        # now if we have values
            mcfg_configure do |config|    # then we need to set them in our configuration
              l_defaults.each do |k,v|    # Set for all defaults
                config.send("#{k}=", v)
              end
            end
            mcfg_set_defaults(l_defaults) if p_options[:set_defaults]  # if requested, lets store our defaults for a future reset
          end
          @mcfg_config #return the current config
        end


        ##
        # This function is one method to change the configuration values.
        #
        # ==== History
        # * <tt>Created: 2016-12-17</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
        #
        # ==== Params
        # * This accepts a block of settings to run on the configuration
        #
        # ==== Returns
        # * <tt>(class Configuration)</tt>
        #   * Returns the updated configuration
        #
        # ==== Examples
        #   DiceMethodThree.mcfg_configure do |config|
        #     config.sides =        p_settings[:sides]
        #     config.num_dice =     p_settings[:num_dice]
        #     config.players =      p_settings[:players]
        #     config.speed =        p_settings[:speed]
        #     config.target_score = p_settings[:target_score]
        #   end
        #
        # ---
        def mcfg_configure
          yield(mcfg_config)
        end

        ##
        # Returns a hash with the configuration settings temporarily merged with the parameter settings.
        # Note: The actual configuration is not changed.
        #
        # ==== History
        # * <tt>Created: 2016-12-17</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
        #
        # ==== Params
        # * <tt>p_options(Hash):</tt> This contains a Hash with settings to override
        #
        #
        # ==== Returns
        # * <tt>(Hash)</tt> Merged Hash of attributes
        #
        # ==== Examples
        #   DiceMethodThree.mcfg_config_override( {
        #       sides: 10,
        #       speed: 0,
        #       players 4: 0
        #   } )
        #   end
        #
        # ---
        def mcfg_config_override(p_options)
          mcfg_config.instance_values.merge(p_options).symbolize_keys
        end

        ##
        # Returns true if the Configuration class has been created
        #
        # ==== History
        # * <tt>Created: 2016-12-17</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
        #
        # ==== Returns
        # * <tt>(Boolean)</tt> Returns true if the Configuration class has been created
        #
        # ==== Examples
        #   DiceMethodThree.mcfg_configured?
        # ---
        def mcfg_configured?
          const_defined?(@config_class_name)
        end

        ##
        # This will reset the configuration. There are multiple options that will effect the various levels
        # of reset.
        #
        # ==== History
        # * <tt>Created: 2016-12-15</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
        #
        # ==== Params
        # * +p_options(Hash)(_default_ {} ):+ The options that tell the reset function what actions to perform
        #   * <tt>:remove_added_attributes (Boolean)(_default_ true ):</tt>  true indicates to remove dynamically added attributes
        #   * <tt>:apply_defaults(Boolean)(_default_ true ):</tt> true indicates to restore the values to any established defaults
        #
        # ==== Returns
        # * <tt>(class Configuration)</tt> Returns the reset configuration
        #
        # ==== Examples
        #   # Remove all dynamic attributes and apply defaults to predefined attributes
        #   DiceMethodThree.mcfg_reset()
        #
        #   # RETAIN all dynamic attributes and apply defaults to all attributes
        #   DiceMethodThree.mcfg_reset(remove_added_attributes: false)
        #
        #   # RETAIN all dynamic attributes BUT do not apply any defaults
        #   DiceMethodThree.mcfg_reset(remove_added_attributes: false, apply_defaults: false)
        #
        # ---
        def mcfg_reset(p_options = {})
          p_options.provide_default(:remove_added_attributes, true)     #set defaults
          p_options.provide_default(:apply_defaults, true)

          # If we are to remove dynamic attributes, then remove them and empty the array
          if p_options[:remove_added_attributes]
            @mcfg_config.remove_attr_accessors(mcfg_attributes_added)
            @established_defaults.except!(*@added_dynamically)
            @added_dynamically = []
          end

          @mcfg_config = config_class.new       # Get Updated Configuration
          if p_options[:apply_defaults]         # Apply Defaults?
            mcfg_setup(@established_defaults)   # Then set them up
          end
          @mcfg_config                          # return updated config
        end

        def mcfg_deconfigure
          remove_const(@config_class_name)
        end

        def mcfg_set_defaults(p_hash)
          #error if an undefined attr is sent
          @established_defaults ||= {}
          p_hash.each do |k,v|
            @established_defaults[k.to_sym] = v
          end
        end

        def mcfg_remove_selected_defaults(*attributes)
          @established_defaults.except!(*attributes)
        end

        def mcfg_remove_all_defaults
          @established_defaults = {}
        end

        def mcfg_defaults
          @established_defaults
        end

        def mcfg_attributes_added
          @added_dynamically.uniq||[]
        end

        def mcfg_change_configuration_class(p_class_name)
          @config_class_name = p_class_name
          self
        end

        private

        def config_class
          self.const_get(@config_class_name)
        end



      end
    end
end
