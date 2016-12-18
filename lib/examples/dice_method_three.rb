require 'marskal/module_configurator'

##
# This module is an example of using *Method 3* of the ModuleConfigurator.
#
# ==== Method 3
# In Method 3, the entire configuration process will be dynamic. This means that *NO* class Configuration will be
# defined in the static code.
# 
# Instead, we will build/add all attributes dynamically during the loading and/or running process of Ruby.
# * The Required <tt>class Configuration</tt> will be dynamically created by <tt>ModuleConfiguration.setup</tt> method.
# * Additional config options/settings are added on afterwards
#
# In this example we have a simple Dice Game to play. The winner is the first one to reach a target score.
#
# ==== History
# * <tt>Created: 2016-12-17</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
#
module DiceMethodThree
  include Marskal::ModuleConfigurator       #this will provide access to the ModuleConfigurator methods

  # Establish Default values for our configuration
  DEFAULTS = {
      sides:        6,
      num_dice:     1,
      players:      2,
      speed:        1,
      target_score: 25
  }

  ##
  # This method simply rolls the dice and returns total
  #
  # ==== History
  # * <tt>Created: 2016-12-17</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
  #
  # ==== Returns
  # * <tt>(Integer)</tt> the sum total of all dice thrown/rolled
  #
  # ==== Examples
  #  DiceMethodThree.roll                           #=> Use existing configuration to roll the dice
  # ---
  def self.roll
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
  # * <tt>Created: 2016-12-17</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
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
  #  DiceMethodThree.play                           #=> Use existing configuration to play game
  #  DiceMethodThree.play( players: 3, num_dice:2)  #=> Play game but use 3 players and 2 dice
  #
  # ---
  def self.play(p_options = {})
    p_options  = config_override(p_options)  # config_override is  part of ModuleConfigurator

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
    puts "\nFinal Tally:\n"
    scores.sort_and_include_index.reverse.each do |score, player|
      puts "\tPlayer # #{player+1} ==> #{score}"
    end

    winner+1

  end

  ##
  # This method simulates multiple ways to play the game and display cumulative results
  #
  # ==== History
  # * <tt>Created: 2016-12-17</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
  #
  # ==== Returns
  # * <tt>(Array)</tt> An Array of winning players
  #
  # ==== Examples
  # * Review the code documentation closely to see the many ways to change the configuration or just temporarily
  #   override the game configuration settings
  #
  #  DiceMethodThree.simulate_games()  #=> Simulate multiple games with various styles of changed settings.
  #
  # ---
  def self.simulate_games(p_config_style = :hash)
    unless [:hash, :configure].include?(p_config_style)
      raise ArgumentError.new("Invalid Style: Choices Are #{[:hash, :configure].map(&:inspect).join(', ')}")
    end

    # To show how the configuration would be built outside of the calling module,
    # I created a separate +DiceThreeExamples+ module to demonstrate
    # We will only call this if the configuration has yet to be defined
    unless configured?
      if p_config_style == :configure
        DiceThreeExamples.build_config_using_configure(DEFAULTS)
      else
        DiceThreeExamples.build_config_using_hash(DEFAULTS)
      end
    end

    winners = []    #store the winners of each simulation

    winners << play                                           # Play with Existing Configuration
    winners << play(players: 3, target_score: 15)             # Temporarily override settings
    winners << play(num_dice: 5, target_score: 200, speed: 0) # Temporarily override settings

    # Important Note: a rest will remove all the dynamically created attributes
    # but will NOT remove the class Configuration that was created.
    # It simply cleans the slate of settings to be setup as needed for future use.
    self.reset  #lets reset, in this example all access to settings will be removed since we created them dynamically

    #if we want to COMPLETELY remove our custom configuration we can use the ModuleConfigurator's 'deconfgure' method
    #Example:
    puts self.configured? #returns true if configured
    self.deconfigure      #lets wipe out the entire configuration
    puts self.configured? # now is 'false'
                          # if we now tried self.configuration, we would get an error


    puts "\nFinal Results:"
    winners.each_with_index do |winner, idx|
      puts "\tThe Winner of Game #{idx + 1} was Player # #{winner}"
    end

    winners
  end

end



##
# Module created for support testing DiceMethodThree configuration styles
#
module DiceThreeExamples

  ##
  # This method shows how to dynamically setup a configuration for the module DiceMethodThree. In this style,
  # only one call to +setup+ is required. Setup will create and add attributes as needed and will set the default values
  #
  # ==== History
  # * <tt>Created: 2016-12-17</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
  #
  # ==== Returns
  # * <tt>(Configuration)</tt> The New Configuration for the module
  #
  # ==== Examples
  #
  #  DEFAULTS = {
  #      sides:        6,
  #      num_dice:     1,
  #      players:      2,
  #      speed:        1,
  #      target_score: 25
  #   }
  #
  #  DiceThreeExamples.build_config_using_hash(DEFAULTS)
  #
  # ---
  def self.build_config_using_hash(p_settings)
    DiceMethodThree.setup( {
                               sides:        p_settings[:sides],
                               num_dice:     p_settings[:num_dice],
                               players:      p_settings[:players],
                               speed:        p_settings[:speed],
                               target_score: p_settings[:target_score]
                           })
  end

  ##
  # This method shows how to dynamically setup a configuration for the module DiceMethodThree. In this style,
  # two steps are needed,
  # 1. Step 1: Call to <tt>setup</tt> to define the new settings and provide access.
  # 2. Step 2: Using a <tt>configure</tt> code block to define the values afterward.
  #
  # ==== History
  # * <tt>Created: 2016-12-17</tt> <b>Mike Urban</b> <mike@marskalgroup.com>
  #
  # ==== Returns
  # * <tt>(Configuration)</tt> The New Configuration for the module
  #
  # ==== Examples
  #
  #  DEFAULTS = {
  #      sides:        6,
  #      num_dice:     1,
  #      players:      2,
  #      speed:        1,
  #      target_score: 25
  #   }
  #
  #  DiceThreeExamples.build_config_using_configure(DEFAULTS)
  #
  # ---
  def self.build_config_using_configure(p_settings)

    DiceMethodThree.setup(p_settings.keys)

    DiceMethodThree.configure do |config|
     config.sides =        p_settings[:sides]
     config.num_dice =     p_settings[:num_dice]
     config.players =      p_settings[:players]
     config.speed =        p_settings[:speed]
     config.target_score = p_settings[:target_score]
    end

    DiceMethodThree.configuration #return the new configuration

  end


end