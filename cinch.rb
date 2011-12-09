require 'cinch'

class Cinch::User; def hash; super; end; end;

$LOAD_PATH << File.dirname(__FILE__) + '/lib'

require 'modules/admin'

require 'cinch/plugins/basic_ctcp'
require 'cinch/plugins/downforeveryone'
require 'cinch/plugins/identify'
require 'cinch/plugins/joker'
require 'cinch/plugins/last_seen'
require 'cinch_hangman'
require 'cinch/plugins/fortune'
require 'plugins/8ball'
require 'plugins/adminhandler'
require 'plugins/antispam' 
require 'plugins/authtest'
require 'plugins/attack'
require 'plugins/autoop'
require 'plugins/autovoice'
require 'plugins/booru'
require 'plugins/botinfo'
require 'plugins/decide'
require 'plugins/delayedrejoin'
require 'plugins/dice'
require 'plugins/jargonfile'
require 'plugins/joinnotice'
require 'plugins/kickban'
require 'plugins/multiqdb'
require 'plugins/ping'
require 'plugins/privtoolbox'
require 'plugins/rainbow'
require 'plugins/remoteadmin'
require 'plugins/russianroulette'
require 'plugins/ryder'
require 'plugins/silly'
require 'plugins/toolbox'
require 'plugins/twitter5'
require 'plugins/urbandictionary'
require 'plugins/weather'


bot = Cinch::Bot.new do
  configure do |c|
    c.nick                = "Azurebot"
    c.server              = "irc.freenode.net"
    c.port                = 6697
    c.channels            = ["#cinch-bots"]
    c.realname            = "Azurebot"
    c.user                = "azurebot"
    c.ssl.use             = true

    c.plugins.plugins = [
      Cinch::Plugins::BasicCTCP,
      Cinch::Plugins::DownForEveryone,
      Cinch::Plugins::Identify,
      Cinch::Plugins::Joker,
      Cinch::Plugins::LastSeen,
      Cinch::Plugins::Hangman,
      Cinch::Plugins::Fortune,
      Plugins::AdminHandler,
      Plugins::AntiSpam::Kicker,
      Plugins::AntiSpam::Lister,
      Plugins::Authtest,
      Plugins::Eightball,
      Plugins::Attack,
      Plugins::AutoOP,
      Plugins::AutoVoice,
      Plugins::Booru,
      Plugins::BotInfo,
      Plugins::Decide,
      Plugins::DelayedRejoin,
      Plugins::Dice,
      Plugins::JargonFile,
      Plugins::JoinNotice,
      Plugins::Kickban,
      Plugins::MultiQDB,
      Plugins::Ping,
      Plugins::PrivToolbox,
      Plugins::Rainbow,
      Plugins::RemoteAdmin,
      Plugins::RussianRoulette,
      Plugins::Ryder,
      Plugins::Silly,
      Plugins::Toolbox,
      Plugins::Twitter5,
      Plugins::UrbanDictionary,
      Plugins::Weather ]
    
    admins = Admin.instance
    admins.password = File.open(File.dirname(__FILE__) + '/config/admin-password', &:gets)

    common_config = {admins: admins}

    c.plugins.options[Plugins::Authtest] = c.plugins.options[Plugins::AdminHandler] = c.plugins.options[Plugins::Toolbox] = c.plugins.options[Plugins::PrivToolbox] = c.plugins.options[Plugins::RemoteAdmin] = c.plugins.options[Plugins::AntiSpam::Lister] = common_config

    c.plugins.options[Plugins::AntiSpam::Kicker] = { limit_commands: 5, limit_seconds: 60 }
    c.plugins.options[Plugins::Attack] = { attack_dictionary: File.dirname(__FILE__) + '/config/attackdict.yaml' }
    c.plugins.options[Plugins::AutoOP] = { enabled_channels: [] }.merge common_config
    c.plugins.options[Plugins::AutoVoice] = { enabled_channels: [] }.merge common_config
    c.plugins.options[Plugins::BotInfo] = { owner: "Azure", bot: c.nick, template: File.dirname(__FILE__) + '/config/info_template.txt'}.merge common_config
    c.plugins.options[Plugins::JoinNotice] = { greetings: File.dirname(__FILE__) + '/config/greetings/freenode/', filext: '.txt' }
    c.plugins.options[Plugins::Twitter5] = { access_keys: File.dirname(__FILE__) + '/config/twitter_oauth.yaml' }
  end

end

bot.start
