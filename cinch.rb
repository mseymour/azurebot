#gem 'cinch', '>= 2.0.0'
require 'cinch'
require 'cinch/logger/zcbot_logger'

class Cinch::User; def hash; super; end; end;

$LOAD_PATH << File.dirname(__FILE__) + '/lib'

require 'modules/admin'

require 'cinch/plugins/basic_ctcp'
require 'cinch/plugins/downforeveryone'
require 'cinch/plugins/identify'
require 'plugins/8ball'
require 'plugins/adminhandler'
require 'plugins/antispam' 
require 'plugins/authtest'
require 'plugins/attack'
require 'plugins/autoop'
require 'plugins/autovoice'
require 'plugins/booru'
require 'plugins/botinfo'
require 'plugins/byedaddy'
require 'plugins/decide'
require 'plugins/delayedrejoin'
require 'plugins/dice'
require 'plugins/djinfo'
require 'plugins/jargonfile'
require 'plugins/joinnotice'
require 'plugins/kickban'
require 'plugins/macros'
require 'plugins/multiqdb'
require 'plugins/ping'
require 'plugins/privtoolbox'
require 'plugins/rainbow'
require 'plugins/remoteadmin'
require 'plugins/russianroulette'
require 'plugins/ryder'
require 'plugins/silly'
require 'plugins/time_ban'
require 'plugins/toolbox'
require 'plugins/twitter'
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
      Plugins::ByeDaddy,
      Plugins::Decide,
      Plugins::DelayedRejoin,
      Plugins::Dice,
      Plugins::DJInfo,
      Plugins::JargonFile,
      Plugins::JoinNotice,
      Plugins::Kickban,
      Plugins::Macros,
      Plugins::MultiQDB,
      Plugins::Ping,
      Plugins::PrivToolbox,
      Plugins::Rainbow,
      Plugins::RemoteAdmin,
      Plugins::RussianRoulette,
      Plugins::Ryder,
      Plugins::Silly,
      Plugins::TimeBan,
      Plugins::Toolbox,
      Plugins::Twitter::Client,
      Plugins::UrbanDictionary,
      Plugins::Weather ]
    
    admins = Admin.instance
    admins.password = File.open(File.dirname(__FILE__) + '/config/admin-password', &:gets)

    common_config = {admins: admins}

    c.plugins.options[Plugins::Authtest] = c.plugins.options[Plugins::AdminHandler] = c.plugins.options[Plugins::Toolbox] = c.plugins.options[Plugins::PrivToolbox] = c.plugins.options[Plugins::RemoteAdmin] = c.plugins.options[Plugins::AntiSpam::Lister] = common_config

    c.plugins.options[Plugins::AntiSpam::Kicker] = { limit_commands: 5, limit_seconds: 30 }
    c.plugins.options[Plugins::Attack] = { attack_dictionary: File.dirname(__FILE__) + '/config/attackdict.yaml' }
    c.plugins.options[Plugins::AutoOP] = { enabled_channels: [] }.merge common_config
    c.plugins.options[Plugins::AutoVoice] = { enabled_channels: [] }.merge common_config
    c.plugins.options[Plugins::BotInfo] = { owner: "Azure", bot: c.nick, template_path: File.dirname(__FILE__) + '/config/info_template.txt'}.merge common_config
    c.plugins.options[Plugins::DJInfo] = { dj_info: File.dirname(__FILE__) + '/config/cr_dj_info.yaml' }
    c.plugins.options[Plugins::JoinNotice] = { greetings: File.dirname(__FILE__) + '/config/greetings/freenode/', filext: '.txt' }
    c.plugins.options[Plugins::Macros] = { macro_yaml_path: File.dirname(__FILE__) + '/config/macros.yaml' }
    c.plugins.options[Plugins::Twitter::Client] = { access_keys: File.dirname(__FILE__) + '/config/twitter_oauth.yaml' }
  end

end

bot.loggers << Cinch::Logger::ZcbotLogger.new(open('/home/azure/bots/logs/bot/freenode-zcbot.log','a'))
bot.loggers << Cinch::Logger::FormattedLogger.new(open('/home/azure/bots/logs/freenode.log','a')) # set up logrotate to rotate weekly, and to keep the last four logs.

bot.start
