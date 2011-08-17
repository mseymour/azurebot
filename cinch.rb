require 'cinch'
$nick = "Azurebot"

class Cinch::User; def hash; super; end; end;

require_relative 'plugins/modules/admin'

require 'cinch/plugins/basic_ctcp'

require_relative 'plugins/plugins/8ball'
require_relative 'plugins/plugins/authtest'
require_relative 'plugins/plugins/adminhandler'
require_relative 'plugins/plugins/attack'
require_relative 'plugins/plugins/autoop'
require_relative 'plugins/plugins/autovoice'
require_relative 'plugins/plugins/booru'
require_relative 'plugins/plugins/botinfo'
require_relative 'plugins/plugins/decide'
require_relative 'plugins/plugins/dice'
require_relative 'plugins/plugins/joinnotice'
require_relative 'plugins/plugins/kickban'
require_relative 'plugins/plugins/multiqdb'
require_relative 'plugins/plugins/privtoolbox'
require_relative 'plugins/plugins/rainbow'
require_relative 'plugins/plugins/ryder'
require_relative 'plugins/plugins/silly'
require_relative 'plugins/plugins/toolbox'
require_relative 'plugins/plugins/twitter5'
require_relative 'plugins/plugins/weather'


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
			Authtest, AdminHandler, Cinch::Plugins::BasicCTCP, Eightball, Attack, AutoOP, AutoVoice, Booru, BotInfo, Decide, 
			Dice, JoinNotice, Kickban, MultiQDB, PrivToolbox, Rainbow, Ryder, Silly, Toolbox, Twitter5, Weather]
		
		admins = Admin.instance
		admins.password = File.open('G:/bot/config/admin-password', &:gets)

		common_config = {admins: admins}

		c.plugins.options[Authtest] = c.plugins.options[AdminHandler] = c.plugins.options[Toolbox] = c.plugins.options[PrivToolbox] = common_config

		c.plugins.options[Attack] = { attack_dictionary: 'G:/bot/config/attackdict.yaml' }
		c.plugins.options[AutoOP] = { enabled_channels: [] }.merge common_config
		c.plugins.options[AutoVoice] = { enabled_channels: [] }.merge common_config
		c.plugins.options[BotInfo] = { owner: "Azure", template: 'G:/bot/config/info_template.txt'}.merge common_config
		c.plugins.options[JoinNotice] = { greetings: 'G:/bot/config/greetings/freenode/', filext: '.txt' }
		c.plugins.options[Twitter5] = { access_keys: 'G:/bot/config/twitter_oauth.yaml' }
	end

end

bot.start