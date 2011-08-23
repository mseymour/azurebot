require 'cinch'
$nick = "Azurebot|ChangeThis"

$LOAD_PATH << File.dirname(__FILE__) + '/lib'

require 'modules/admin'

require 'cinch/plugins/basic_ctcp'
require 'cinch/plugins/downforeveryone'
require 'cinch/plugins/identify'
require 'plugins/8ball'
require 'plugins/adminhandler'
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
require 'plugins/privtoolbox'
require 'plugins/rainbow'
require 'plugins/ryder'
require 'plugins/silly'
require 'plugins/toolbox'
require 'plugins/twitter5'
require 'plugins/uptime'
require 'plugins/urbandictionary'
require 'plugins/weather'


bot = Cinch::Bot.new do
	configure do |c|
		c.nick            = $nick
		c.server          = "irc.freenode.net"
		c.port            = 6697
		c.channels        = ["#shakesoda"]
		c.realname        = "Azurebot"
		c.user            = "ABIII"
		c.ssl.use         = true

		c.plugins.plugins = [
			Cinch::Plugins::BasicCTCP,
			Cinch::Plugins::DownForEveryone,
			Cinch::Plugins::Identify,
			Plugins::AdminHandler,
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
			Plugins::PrivToolbox,
			Plugins::Rainbow,
			Plugins::Ryder,
			Plugins::Silly,
			Plugins::Toolbox,
			Plugins::Twitter5,
			Plugins::Uptime,
			Plugins::UrbanDictionary,
			Plugins::Weather ]
		
		admins = Admin.instance
		admins.password = File.open('G:/bot/config/admin-password', &:gets)

		common_config = {admins: admins}

		c.plugins.options[Plugins::Authtest] = c.plugins.options[Plugins::AdminHandler] = c.plugins.options[Plugins::Toolbox] = c.plugins.options[Plugins::PrivToolbox] = common_config

		c.plugins.options[Plugins::Attack] = { attack_dictionary: 'G:/bot/config/attackdict.yaml' }
		c.plugins.options[Plugins::AutoOP] = { enabled_channels: [] }.merge common_config
		c.plugins.options[Plugins::AutoVoice] = { enabled_channels: [] }.merge common_config
		c.plugins.options[Plugins::BotInfo] = { owner: "Azure", template: 'G:/bot/config/info_template.txt'}.merge common_config
		c.plugins.options[Plugins::JoinNotice] = { greetings: 'G:/bot/config/greetings/freenode/', filext: '.txt' }
		c.plugins.options[Plugins::Twitter5] = { access_keys: 'G:/bot/config/twitter_oauth.yaml' }
	end

end

bot.start