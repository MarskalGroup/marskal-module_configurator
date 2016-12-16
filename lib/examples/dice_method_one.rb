##
# This module is an example of using *Method 1* of the ModuleConfigurator.
#
# ==== Method 1
# In Method 1 the confgiuration is defined by the calling(including) module
# * The Required <tt>class Configuration</tt> is defined *completely* by the calling module.
# * The *calling module* is the module with the <tt>include Marskal::ModuleConfigurator</tt>
# * In this case <tt>DiceMethodOne</tt> is the calling module
#
# In this example we have a simple Dice Game to play. The winner is the first one to reach a target score.
#
# ==== History
# * <tt>Created: 2016-12-16</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
#
module DiceMethodOne
  include Marskal::ModuleConfigurator       #this will provide access to the ModuleConfigurator methods

  # Establish Default values for our configuration
  DEFAULTS = {
      sides:        6,
      num_dice:     1,
      players:      2,
      speed:        1,
      target_score: 100
  }

  ##
  # In Method one this module would be COMPLETELY responsible for the donfiguration variables.
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
  #  my_config = DiceMethodOne::Configuration.new
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
    #  DiceMethodOne.roll   #=> Use existing configuration to roll the dice
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
  #  DiceMethodOne.roll                           #=> Use existing configuration to roll the dice
  # ---
  def self.roll
    @configuration = self.configuration   #even though I expected to be able to use @configuration without
                                          #first calling self.configuration. It doesn't work on first call
                                          #So for now always access the default config as self.configuration.
    l_total = 0                                 #initialize dice total
    @configuration.num_dice.times do |ctr|      #throw the dice as many times as configured
      l_total += rand(1..@configuration.sides)  #keep a total
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
  #  DiceMethodOne.play                           #=> Use existing configuration to play game
  #  DiceMethodOne.play( players: 3, num_dice:2)  #=> Play game but use 3 players and 2 dice
  #
  # ---
  def self.play(p_options = {})
    # this is a one line way to merge the configuration
    # p_options = self.configuration.instance_values.merge(p_options).symbolize_keys
    # p_options = self.configuration.instance_values.merge(p_options).symbolize_keys
    p_options  = config_override  # config_override is  part of ModuleConfigurator

    winner = nil                                    #no winner yet
    scores = Array.new(p_options[:players], 0)      #initialize array to keep scores
    who_goes_first = scores.shuffle.first           #Randomly see who goes first

    puts "Player #{who_goes_first + 1} will roll first...\n\n"
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
      sleep p_options[:speed]                                 #pause after each round
      leader = scores.map.with_index.sort.map(&:last).last    #get current leader
      puts "At the end of round 1 the leader is #{leader+1}, score: #{scores[leader]}\n\n"
      round += 1                                              #next round
    end

    # display results
    puts "\nGames is Over: The Winner is Player #{winner+1} with a score of #{scores[winner]}"
    puts "\nFinal Tally:\n"
    scores.map.with_index.sort.map(&:last).reverse.each do |player|
      puts "\tPlayer#{player+1} ==> #{scores[player]}"
    end

    winner+1

  end

  ##
  # This method simulates multiple ways to play the game and display cumulative results
  #
  # ==== History
  # * <tt>Created: 2016-12-16</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
  #
  # ==== Examples
  # * Review the code documentation closely to see the many ways to change the configuration or just temporarily
  #   override the game configuration settings
  #
  #  DiceMethodOne.simulate_games()  #=> Simulate multiple games with various styles of changed settings.
  #
  # ==== Returns
  # * <tt>(Array)</tt> An Array of winning players
  #
  # ---
  def self.simulate_games()
    winners = []    #store the winners of each simulation

    winners << play                                           # Play with Existing Configuration
    winners << play(players: 3, target_score: 50)             # Temporarily override settings
    winners << play(num_dice: 5, target_score: 200, speed: 0) # Temporarily override settings

    # Now lets change the actual default configuration using _Style 1:_ *Direct Assign*
    # DiceMethodOne.configuration.target_score = 20    #directly change the configuration
    # winners << play

    # Now lets change the actual default configuration using _Style 2:_ *Variable Assignment*
    my_config = DiceMethodOne::Configuration.new
    my_config.players = 3
    my_config.sides = 12
    my_config.target_score = 50
    DiceMethodOne.configuration = my_config
    winners << play

    DiceMethodOne.reset  #lets reset to make sure we are back to our default values before our next example

    # Now lets change the actual default configuration using _Style 3:_ *Block Code Assignment*
    # This is most typically how it would be done in a real-life situation.
    # Generally this would be done in an initializer file often located in the config/initializers of an app
    # But this can be initialized anywhere as you see here.
    DiceMethodOne.configure do |config|
      config.players = 5
      config.speed  = 0
      config.sides = 20
      config.target_score = 250
    end

    winners << play

    puts 'Final Results:'
    winners.each_with_index do |winner, idx|
      puts "\tThe Winner of Game #{idx + 1} was Player # #{winner+1}"
    end

    winners
  end

end

