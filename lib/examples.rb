require 'examples/dice_method_one'
require 'examples/dice_method_two'
require 'examples/dice_method_three'
require 'examples/defaults_examples'
# require 'examples/object'

require 'marskal/module_configurator'

module Junk
  include Marskal::ModuleConfigurator

  class Configuration
    attr_accessor :class_inline_var

    def initialize
      @class_inline_var = 7654
    end
  end


end




class Klass
  attr_accessor :inline

  def initialize
    puts "here...."
    @inline = 55
  end


  def add_attr(name, value)
    self.class.send(:attr_accessor, name)
    instance_variable_set("@#{name}", value)
  end

  def undo
    Klass.undef_method :inline
  end

end


class Dummy
  attr_accessor :var
  def initialize
    @var = 99
  end

  def remove
    remove_instance_variable(:@var)
    # self.class.undef_method :var
    self.class.to_s.constantize.send(:undef_method, :var)
  end

  def self.undo
    cc = Dummy == self
    # undef_method :var
    # Dummy.class.send(:undef_method, :var)

    name.constantize.send(:undef_method, :var)
  end


end

class Parent
  def hello
    puts "In parent"
  end
end
class Child < Parent
  def hello
    puts "In child"
  end

  def remove
    undef_method :hello
  end

  def self.undo
    undef_method :hello
  end
end


#a dummy class to use for testing
class MyClass

  #dummy test attributes
  attr_accessor :attr1,  :attr2, :attr3
  @xx = [1,2,3]

  def initialize
    @attr1 = 1
    @attr2 = 2
    @attr3 = 3
  end

  def self.my_method #(name, age)
    my_method do |name|
      puts "#{name}"
    end
  end

  def self.runme

  end

  def self.configure
    yield(@xx)
  end

end



