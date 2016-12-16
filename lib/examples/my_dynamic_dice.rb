require 'marskal/module_configurator'

module MyDynamicDice
  include Marskal::ModuleConfigurator

  def self.roll
    @configuration = self.configuration
    l_total = 0
    @configuration.number_of_dice.times do
      l_total += rand(1..@configuration.sides)
    end
    l_total
  end

  def self.prepare_game(target, dice_sides, num_dice, speed = 1, num_players = 2)
    setup({ target_score: target,
            sides: dice_sides,
            number_of_dice: num_dice,
            players: num_players,
            speed: speed
    })


  end

  def self.play_first_to_target_score
    winner = nil
    scores = Array.new(@configuration.players, 0)
    who_goes_first = scores.shuffle.first

    puts "Player #{who_goes_first + 1} will roll first...\n\n"
    round = 0
    while scores.max < @configuration.target_score do
      @configuration.players.times do |player|
        player_roll = roll
        scores[player] += player_roll
        puts "Player #{player + 1} rolls a #{player_roll}\n"
        sleep @configuration.speed
        if scores[player] >= @configuration.target_score
          winner = player
        end
      end
      leader = scores.map.with_index.sort.map(&:last).last
      puts "At the end of round 1 the leader is #{leader+1}, score: #{scores[leader]}\n\n"
      round += 1
    end

    puts "\nGames is Over: The Winner is Player #{winner+1} with a score of #{scores[winner]}"
    puts "\nFinal Tally:\n"
    scores.map.with_index.sort.map(&:last).reverse.each do |player|
      puts "\tPlayer#{player+1} ==> #{scores[player]}"
    end

    winner

  end


end