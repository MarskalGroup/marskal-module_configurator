require 'marskal/module_configurator'

##
# This module is an example of using *Method 2* of the ModuleConfigurator.
#
# ==== Method 2
# In Method 2, as in Method 1, the configuration is defined by the calling(including) module.
# However, we will add on attributes dynamically, after the initial configuration.
# * The Required <tt>class Configuration</tt> is defined by the calling module.
# * Additional config options/settings are added on afterwards
# * The *calling module* is the module with the <tt>include Marskal::ModuleConfigurator</tt>
# * In this case <tt>DiceMethodTwo</tt> is the calling module
#
# In this example we have a simple Dice Game to play. The winner is the first one to reach a target score.
#
# ==== History
# * <tt>Created: 2016-12-16</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
#
module DiceMethodTwo
  include Marskal::ModuleConfigurator       #this will provide access to the ModuleConfigurator methods

  # Establish Default values for our configuration
  DEFAULTS = {
      sides:        6,
      num_dice:     1,
      players:      2,
      speed:        1,
      target_score: 25
  }

  # These attributes will be added dynamically
  NEW_SETTINGS = [:color, :material]



  ##
  # In Method one this module would be COMPLETELY responsible for the configuration variables.
  #
  # Note::  Method one is conceptual only. The ModuleConfigurator will work with one or all methods
  #         without specifying a method
  #
  # ==== History
  # * <tt>Created: 2016-12-11</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
  #
  # ==== Params
  # * In this example we are not allowing any param overrides, but you could if you desired.
  #
  # ==== Examples
  #  my_config = DiceMethodTwo::Configuration.new
  #
  # ---
  class Configuration

    #various settings for our dice game
    attr_accessor :sides, :num_dice, :players, :speed,:target_score

    ##
    # This method sets all the defaults for the game configuration
    #
    # ==== History
    # * <tt>Created: 2016-12-16</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
    #
    # ==== Params
    # * No parameters for this example. In real usage, the options would be like be part of the parameters so
    #   the defaults could be changed.
    #
    # ==== Returns
    # * <tt>(self)</tt> The new instance of the class
    #
    # ==== Examples
    #  DiceMethodTwo.roll   #=> Use existing configuration to roll the dice
    # ---
    def initialize()
      @sides    = DEFAULTS[:sides]
      @num_dice = DEFAULTS[:num_dice]
      @players  = DEFAULTS[:players]
      @speed =    DEFAULTS[:speed]
      @target_score = DEFAULTS[:target_score]
    end
  end

  ##
  # This method simply rolls the dice and returns total
  #
  # ==== History
  # * <tt>Created: 2016-12-16</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
  #
  # ==== Returns
  # * <tt>(Integer)</tt> the sum total of all dice thrown/rolled
  #
  # ==== Examples
  #  DiceMethodTwo.roll                           #=> Use existing configuration to roll the dice
  # ---
  def self.roll
    l_total = 0                                 #initialize dice total
     @mcfg_config.num_dice.times do |ctr|      #throw the dice as many times as configured
      l_total += rand(1.. @mcfg_config.sides)  #keep a total
    end
    l_total                                     # Return total of all dice thrown
  end


  ##
  # This method plays a game that ends when the target score is reached.
  #
  # ==== History
  # * <tt>Created: 2016-12-16</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
  #
  # ==== Params
  # * <tt>p_options(Hash)(_defaults_ to: {} ):</tt> The options to use to play the game. All options default to that stored in the configuration
  #   * <tt>:sides (Integer):</tt>        Number of sides for each dice
  #   * <tt>:num_dice(Integer):</tt>      Number of dice to throw/roll
  #   * <tt>:players(Integer):</tt>       Number of players
  #   * <tt>:speed(Numeric):</tt>         Number of seconds to pause between each round
  #   * <tt>:target_score(Numeric):</tt>  The first player to reach this score wins
  #
  # ==== Returns
  # * <tt>(Integer)</tt> returns the number of Player that won
  #
  # ==== Examples
  #  DiceMethodTwo.play                           #=> Use existing configuration to play game
  #  DiceMethodTwo.play( players: 3, num_dice:2)  #=> Play game but use 3 players and 2 dice
  #
  # ---
  def self.play(p_options = {})
    # Gather up the settings that have yet to be defined
    attrs_to_setup = NEW_SETTINGS.reject {|k| @mcfg_config.respond_to?(k.to_s)}

    # Now, add any new fields to our configuration
    unless attrs_to_setup.empty?
      # This isn't how I would set it up in real life, but for demonstration purposes
      # we will call setup using a hash with defaults if even one attribute was sent.
      if NEW_SETTINGS.any? { |key| p_options.has_key?(key) }
        defaults = {}
        NEW_SETTINGS.each do |k|
          defaults[k] = p_options[k]
        end
        add_new_attributes_no_defaults(defaults)          #pass as a hash to setup
      else
        add_new_attributes_no_defaults(attrs_to_setup)    #otherwise, just pass array of attributes to define
                                                          #after this you will be able to access atrributes directly
                                                          # example self.configuration.color or  @mcfg_config.color
      end

    end

    # this is a one line way to merge the configuration
    p_options  = mcfg_config_override(p_options)  # mcfg_config_override is  part of ModuleConfigurator

    winner = nil                                    #no winner yet
    scores = Array.new(p_options[:players], 0)      #initialize array to keep scores
    who_goes_first = scores.shuffle.first           #Randomly see who goes first

    puts "\nPlayer #{who_goes_first + 1} will roll first...\n\n"
    round = 0                                           #keep track of rounds
    while scores.max < p_options[:target_score] do      # Play until target is reached
      p_options[:players].times do |player|             # loop for each player to score
        player_roll = roll                              # Let's roll!
        scores[player] += player_roll                           #store score
        puts "Player #{player + 1} rolls a #{player_roll}\n"
        if scores[player] >= p_options[:target_score]           #see if we have a winner
          winner = player
        end
      end
      sleep p_options[:speed]
      leader = scores.map.with_index.sort.map(&:last).last    #get current leader
      puts "At the end of round 1 the leader is #{leader+1}, score: #{scores[leader]}\n\n"
      round += 1                                              #next round
    end

    # display results
    puts "\nGames is Over: The Winner is Player #{winner+1} with a score of #{scores[winner]}"
    puts "\tThe games was played with #{p_options[:color]} dice made of #{p_options[:material]}"
    puts "\n\tFinal Tally:\n"
    scores.sort_and_include_index.reverse.each do |score, player|
        puts "\tPlayer # #{player+1} ==> #{score}"
    end

    winner+1

  end

  ##
  # This method shows how to user ModuleConfigurator's +mcfg_setup+ method to add a list of new settings/attributes
  # *WITHOUT* any defaults.
  #
  # Note:: This example simply calls DiceMethodTwo.mcfg_setup. Refer to the documentation for that method for more details.
  #
  # ==== History
  # * <tt>Created: 2016-12-16</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
  #
  # ==== Returns
  # * <tt>(Configuration)</tt> Returns the updated configuration
  #
  # ==== Examples
  #   DiceMethodTwo.add_new_attributes_no_defaults(:msg, :date, :size)  #adds three new settings to the config of DiceMethodTwo
  #
  #   # Now these new settings can be set in many ways
  #   DiceMethodTwo.mcfg_config.msg = 'Direct Access Example'   #direct access
  #
  #   c = DiceMethodTwo.mcfg_config                             #variable
  #   c.msg = 'Example via a variable'
  #
  #   DiceMethodTwo.mcfg_configure |config|                        #code block using 'configure' method
  #       config.msg = 'Example via a code block'
  #       config.date Date.today
  #       config.size = 999
  #   end
  #
  # ---
  def self.add_new_attributes_no_defaults(attributes)
    DiceMethodTwo.mcfg_setup(attributes)
  end

  ##
  # This method shows how to user ModuleConfigurator's +mcfg_setup+ method to add a list of new settings/attributes
  # *WITH* any defaults.
  #
  # Note:: This example simply calls DiceMethodTwo.mcfg_setup. Refer to the documentation for that method for more details.
  #
  # ==== History
  # * <tt>Created: 2016-12-16</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
  #
  # ==== Returns
  # * <tt>(Configuration)</tt> Returns the updated configuration
  #
  # ==== Examples
  #   DiceMethodTwo.add_new_attributes_no_defaults('Red', 'Steel') #instructs to add new attributes and their values
  #
  # ---
  def self.add_new_attributes_with_defaults(p_color, p_material)
    # In this code, we are going to give the dice color and material dynamically using mcfg_setup
    # This will add to an existing Configuration class (it will actually create class Configuration if needed)
    DiceMethodTwo.mcfg_setup(
        color:     'Red',
        material:  'Plastic'
    )
  end

  ##
  # This method simulates multiple ways to play the game and display cumulative results
  #
  # ==== History
  # * <tt>Created: 2016-12-16</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
  #
  # ==== Returns
  # * <tt>(Array)</tt> An Array of winning players
  #
  # ==== Examples
  # * Review the code documentation closely to see the many ways to change the configuration or just temporarily
  #   override the game configuration settings
  #
  #  DiceMethodTwo.simulate_games()  #=> Simulate multiple games with various styles of changed settings.
  #
  # ---
  def self.simulate_games()
    winners = []    #store the winners of each simulation


    winners << play                                           # Play with Existing Configuration
    winners << play(players: 3, target_score: 50)             # Temporarily override settings
    winners << play(num_dice: 5, target_score: 200, speed: 0) # Temporarily override settings

    # Now lets change the actual default configuration using _Style 1:_ *Direct Assign*
    # DiceMethodTwo.mcfg_config.target_score = 20    #directly change the configuration
    # winners << play

    # Now lets change the actual default configuration using _Style 2:_ *Variable Assignment*
    my_config = DiceMethodTwo::Configuration.new
    my_config.players = 3
    my_config.sides = 12
    my_config.target_score = 50
    DiceMethodTwo.mcfg_config = my_config
    winners << play

    DiceMethodTwo.mcfg_reset  #lets reset to make sure we are back to our default values before our next example

    # Now lets change the actual default configuration using _Style 3:_ *Block Code Assignment*
    # This is most typically how it would be done in a real-life situation.
    # Generally this would be done in an initializer file often located in the config/initializers of an app
    # But this can be initialized anywhere as you see here.
    DiceMethodTwo.mcfg_configure do |config|
      config.players = 5
      config.speed  = 0
      config.sides = 20
      config.target_score = 250
    end

    winners << play         #add wo winners list

    #display results
    puts "\nFinal Results:"
    winners.each_with_index do |winner, idx|
      puts "\tThe Winner of Game #{idx + 1} was Player # #{winner}"
    end

    winners
  end


end

