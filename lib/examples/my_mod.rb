

module MyMod
  attr_accessor :configuration, :zzz

  class Configuration
    attr_accessor :access_key, :secret_key, :personal_key

    def initialize
      @access_key = 1
      @secret_key = 2
      @personal_key = 3
    end
  end


  def self.zzz
    987
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end


  def self.roll
    x = @zzz
    l_total = 0
    @configuration.access_key.times do
      l_total += rand(1..@configuration.secret_key)
    end
    l_total
  end


  def self.xxx
    "==> #{@configuration}"
  end

  def self.yyy
    puts "x==> #{self.configuration}"
  end

end