require 'marskal/module_configurator'

module MyDice
  include Marskal::ModuleConfigurator

  DEFAULT_SIDES = 6
  DEFAULT_NUMBER_OF_DICE = 1

  class Configuration
    attr_accessor :sides, :number_of_dice, :total, :values

    def initialize()
      @sides = MyDice::DEFAULT_SIDES
      @number_of_dice = MyDice::DEFAULT_NUMBER_OF_DICE
    end
  end

  def self.roll
    @configuration = self.configuration
    l_total = 0
    @configuration.number_of_dice.times do
      l_total += rand(1..@configuration.sides)
    end
    l_total
  end

  def self.setup_enhanced_dice()
    #lets add color to our dice
    self.setup(color: 'red')
  end

  def self.roll_enhanced_results
    @configuration = self.configuration
    return {
        total:    roll,
        color:    @configuration.color,
        num_dice: @configuration.number_of_dice
    }
  end


end