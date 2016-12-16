class MyMod

  def self.play_first_to_target_score(p_options = {})
    p_options = self.configuration.instance_values.merge(p_options).symbolize_keys
    winner = nil
    scores = Array.new(p_options[:players], 0)
    who_goes_first = scores.shuffle.first

    puts "Player #{who_goes_first + 1} will roll first...\n\n"
    round = 0
    while scores.max < p_options[:target_score] do
      p_options[:players].times do |player|
        player_roll = roll
        scores[player] += player_roll
        puts "Player #{player + 1} rolls a #{player_roll}\n"
        sleep p_options[:speed]
        if scores[player] >= p_options[:target_score]
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

    winner+1

  end
  
end