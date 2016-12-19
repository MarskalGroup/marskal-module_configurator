require 'pp'


module DefaultsExperiments
  include Marskal::ModuleConfigurator       #this will provide access to the ModuleConfigurator methods

  # Establish Default values for our configuration
  DEFAULTS = {
      sides:        6,
      num_dice:     1,
      players:      2,
      speed:        1,
      target_score: 25
  }

  class Configuration

    #various settings for our dice game
    attr_accessor :sides, :num_dice, :players, :speed,:target_score

    def initialize()
      @sides    = DEFAULTS[:sides]
      @num_dice = DEFAULTS[:num_dice]
      @players  = DEFAULTS[:players]
      @speed =    DEFAULTS[:speed]
      @target_score = DEFAULTS[:target_score]
    end
  end

  def self.huh
    # Now lets add some custom dynamic settings
    mcfg_setup({ color: 'RED', material: 'Steel', sides: 20 }, set_defaults: true )
     mcfg_reset
    c =  @mcfg_config
    c
  end

  def self.experiment
    #first lets change the defaults of some of the existing predefined attributes
    mcfg_set_defaults(
        sides: 10,
        players: 5
    )

    # Now lets add some custom dynamic settings
    mcfg_setup({ color: 'RED', material: 'Steel'}, set_defaults: true )

    #now lets change one of our custom settings defaults
    mcfg_set_defaults(material: 'Plastic')

    # Now lets add some a dynamic settings and specifically ask NOT to set defaults (set_defaults: false)
    mcfg_setup({ weight: 'Heavy' }, set_defaults: false )

    # Now lets add some a dynamic settings and allow the default to be used (default: set_defaults = false)
    mcfg_setup({ bet: '$100' })

    pp(mcfg_defaults) #prints {:sides=>10, :players=>5, :color=>"RED", :material=>"Plastic"}

     mcfg_reset(remove_added_attributes: false)  #now lets reset, but keep our attributes and defaults

    pp( @mcfg_config)  #the output below is produced
    # #<DefaultsExperiments::Configuration:0x000000045f7838
    #     @color="RED",
    #     @material="Plastic",
    #     @num_dice=1,
    #     @players=5,
    #     @sides=10,
    #     @speed=1,
    #     @target_score=25>

    #Notice How 'weight' and 'bet' do not appear. HOWEVER, they are still accessible
    # Let's test that out
     @mcfg_config.bet = '$200'
    pp( @mcfg_config) #this produces the output below
    # #<DefaultsExperiments::Configuration:0x0000000437f600
    #     @bet="$200",
    #     @color="RED",
    #     @material="Plastic",
    #     @num_dice=1,
    #     @players=5,
    #     @sides=10,
    #     @speed=1,
    #     @target_score=25>

    #Now lets do a default reset which will wipe out access to all dynamically added fields
    #But will leave the predefined class values and apply any defaults to them
     mcfg_reset #reset using defaults

    pp( @mcfg_config) #this produces the output below
    # #<DefaultsExperiments::Configuration:0x000000044a6628
    #     @num_dice=1,
    #     @players=5,
    #     @sides=10,
    #     @speed=1,
    #     @target_score=25>

    begin
       @mcfg_config.weight = 1
    rescue NameError => error
      puts "Error: After Reset, the dynamically added variable is no longer available"
    end

    #now lets reset to original. We will not apply any of the established_defaults
     mcfg_reset(apply_defaults: false)

    pp( @mcfg_config) #this produces the output below
    # #<DefaultsExperiments::Configuration:0x00000004494c48
    #     @num_dice=1,
    #     @players=2,
    #     @sides=6,
    #     @speed=1,
    #     @target_score=25>



     @mcfg_config
  end

end


