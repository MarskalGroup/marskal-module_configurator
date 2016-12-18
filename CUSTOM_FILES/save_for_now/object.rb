require 'marskal/core_ext/symbol'
require 'active_support/core_ext/hash'

module Marskal
  module CoreExt
    ##
    # Extends functionality to Ruby's +Object+ class
    #
    # ==== History
    # * <tt>Created: 2016-12-17</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
    #
    module MyObject

      ##
      # This emulates the +attr_accessor+, +attr_reader+, +attr_writer+ methods of Ruby. The purpose
      # is to allow these to be defined dynamically
      #
      # ==== History
      # * <tt>Created: 2016-12-17</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
      #
      # ==== Extends
      # * Extends Ruby's <tt>Object</tt> class
      #
      # ==== Params
      # * <tt>self(Object):</tt> The Object to apply attribute methods to
      # * <tt>p_attributes(Array):</tt> An Array of attribute symbols to add to the object
      # * <tt>p_type(Symbol):</tt>
      #   * +:both+   => Add both read and write methods to the object (:attr_accessor)
      #   * +:read+   => Add ONLY a read method to the object (:attr_read)
      #   * +:write+  => Add ONLY a write method to the object (:attr_write)
      #
      # ==== Returns
      # * <tt>(self)</tt> self with added attributes
      #
      # ==== Examples
      #   c = MyClass.new
      #
      #   # Note: This is the same as c.add_attr_accessors(:single_var, :both)
      #   c.add_attr_accessors(:single_var)         #=> assigns a read and a write accessor for single_var
      #   c.single_var = 999                        #=> Sets the value of c.single_var to 999
      #   c.single_var                              #=> 999
      #
      #   c.add_attr_accessors(:single_var, :read)  #=> assigns a read only accessor for single_var
      #   c.single_var = 999                        #=> produces an error
      #   c.single_var                              #=> returns nil
      #
      #   c.add_attr_accessors(:single_var, :write) #=> assigns a write only accessor for single_var
      #   c.single_var = 999                        #=> Sets the value of c.single_var to 999
      #   c.single_var                              #=> produces an error
      #
      #   # examples of multiple variables
      #   c.add_attr_accessors([:var1, :var2, :var3, :var4])
      #   c.add_attr_accessors([:var1, :var2, :var3, :var4], :both)
      #   c.add_attr_accessors([:var1, :var2, :var3, :var4], :read)
      #   c.add_attr_accessors([:var1, :var2, :var3, :var4], :write)
      # ---
      def add_attr_accessors(p_attributes, p_type = :both)
        p_type.to_h.assert_valid_keys(:read, :write, :both)    #validate type

        #loop through the accessors to be added
        Array(p_attributes).flatten.each do |k|

          #lets set the write reader if needed
          if [:read, :both].include?(p_type) && !self.respond_to?(k.to_s)   #is there already one defined
            self.class.send(:define_method, k.to_sym) do                    #lets create one as requested
              instance_variable_get('@' + k.to_s)           # equivalent of an attr_reader is created here
            end
          end

          # Lets set the write accessor if needed
          if [:write, :both].include?(p_type) && !self.respond_to?("#{k.to_s}=")  #is there already one defined
            self.class.send(:define_method, "#{k}=".to_sym) do |value|            #lets create one as requested
              instance_variable_set("@" + k.to_s, value)   # equivalent of an attr_writer is created here
            end
          end

        end # end p_attributes..do
        self  #all done return self
      end # end add_attr_accessors

      ##
      # This removes attribute accessors defined +attr_accessor+, +attr_reader+, +attr_writer+ methods of Ruby.
      #
      # Also, this is essentially the reverse of +add_attr_accessors+ method defined in this module
      #
      # ==== History
      # * <tt>Created: 2016-12-17</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
      #
      # ==== Extends
      # * Extends Ruby's <tt>Object</tt> class
      #
      # ==== Params
      # * <tt>self(Object):</tt> The Object to apply attribute methods to
      # * <tt>p_attributes(Array):</tt> An Array of attribute symbols to remove from the object
      # * <tt>p_type(Symbol):</tt>
      #   * +:both+   => Remove both the read and write methods to the object (:attr_accessor)
      #   * +:read+   => Remove ONLY the read method to the object (:attr_read)
      #     * Note: for +:read+, the value assigned to the instance variable will be removed as well
      #   * +:write+  => Remove ONLY the write method to the object (:attr_write)
      #
      # ==== Returns
      # * <tt>(self)</tt> self with added attributes methods removed as requested
      #
      # ==== Examples
      #   class MyClass
      #     attr_accessor :test_var1, :test_var2
      #
      #     def initialize
      #       @test_var1 = 'One'
      #       @test_var2 = 'Two'
      #     end
      #   end
      #
      #   c = MyClass.new  #keep in mind you will need to restart ruby since we just wiped out your attributes
      #
      #   # Note: This is the same as c.add_attr_accessors(:single_var, :both)
      #   c.remove_attr_accessors(:test_var1)   #=> removes both the read and a write accessor for single_var
      #   c.test_var1                           #=> produces an error
      #   c.test_var1 = 999                     #=> produces an error
      #
      #   c = MyClass.new  #keep in mind you will need to restart ruby since we just wiped out your attributes
      #   c.remove_attr_accessors(:test_var1, :write)  #=> removes write accessor, but leaves read and value intact
      #   c.test_var1                           #=> "One"
      #   c.test_var1 = 999                     #=> produces an error
      #
      #   c = MyClass.new  #keep in mind you will need to restart ruby since we just wiped out your attributes
      #   c.remove_attr_accessors(:test_var1, :read)  #=> removes read accessor AND removes the value as well
      #   c.test_var1                           #=> produces an error
      #   c.test_var1 = 999                     #=> This works, but there is no read access to it, so may not be useful
      #
      #
      #   c = MyClass.new  #keep in mind you will need to restart ruby since we just wiped out your attributes
      #   c.add_attr_accessors(:new_var1)       #=>  Now lets use the dynamic method (defined in this module)
      #   c.new_var1 = 999                      #=> Sets the value of c.new_var1 to 999
      #   c.new_var1                            #=> 999
      #   c.remove_attr_accessors(:new_var1)    #=> Now lets remove what we just added
      #   c.new_var1                            #=> produces an error
      #   c.new_var1 = 999                      #=> produces an error
      #
      #
      #   # examples of multiple variables
      #   c.remove_attr_accessors([:var1, :var2, :var3, :var4])
      #   c.remove_attr_accessors([:var1, :var2, :var3, :var4], :both)
      #   c.remove_attr_accessors([:var1, :var2, :var3, :var4], :read)
      #   c.remove_attr_accessors([:var1, :var2, :var3, :var4], :write)
      # ---
      def remove_attr_accessors(p_attributes, p_type = :both)
        p_type.to_h.assert_valid_keys(:read, :write, :both)    #validate type

        #loop thru all the attributes
        Array(p_attributes).flatten.each do |l_attr|

          #Check if we are removing the read accessor
          if [:read, :both].include?(p_type)
            if instance_variable_defined?(:"@#{l_attr}")                   #is an instance variable was set,
              remove_instance_variable(:"@#{l_attr}")     #we first remove it
            end
            if self.methods.include?(l_attr.to_sym)                           #if read method exists
              begin
                # this throws errors without this funky 'class.to_s.constantize' code
                self.class.to_s.constantize.send(:undef_method, l_attr.to_sym)  # Then remove that as well
              rescue NameError
                #do nothing, this happens sometimes, I am not sure why, but for now it seems harmless,
                # so we just continue TODO: Come back later and research this
              end  #end rescue
            end
          end

          #Check if we are removing the write accessor
          if [:write, :both].include?(p_type)
            if self.methods.include?("#{l_attr}=".to_sym)                           #write method exist?
              begin
                # this throws errors without this funky 'class.to_s.constantize' code
                self.class.to_s.constantize.send(:undef_method, "#{l_attr}=".to_sym)  #the remove it
              rescue NameError
                #do nothing, this happens sometimes, I am not sure why, but for now it seems harmless,
                # so we just continue TODO: Come back later and research this
              end  #end rescue
            end
          end

        end # end p_attributes..do
        self #all done return self
      end # end remove_attr_accessors

    end # end MyObject
  end
end

# now that the module has been built, lets extend Ruby's +Object+ class to accept these methods
Object.send(:include, Marskal::CoreExt::MyObject)