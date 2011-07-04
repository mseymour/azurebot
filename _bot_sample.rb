require 'cinch'
require 'yaml'

$nick = "Azurebot"; #for the botinfo script. Will be removed with later versions of Cinch.

require 'cinch/plugins/basic_ctcp'
require 'cinch/plugins/downforeveryone'
require 'cinch/plugins/identify'

require_relative 'plugins/core/commands'
require_relative 'plugins/core/toolbox'
require_relative 'plugins/core/private_toolbox'
require_relative 'plugins/core/kickban'

require_relative 'plugins/fun/attack'
require_relative 'plugins/fun/decide'
require_relative 'plugins/fun/dice'
require_relative 'plugins/fun/dongs'
require_relative 'plugins/fun/fb2kcontrol'
require_relative 'plugins/fun/rainbow'
require_relative 'plugins/fun/ryder'

require_relative 'plugins/informative/botinfo'
require_relative 'plugins/informative/booru'
require_relative 'plugins/informative/twitter5'
require_relative 'plugins/informative/urbandictionary'
require_relative 'plugins/informative/weather'
require_relative 'plugins/informative/qdb'
require_relative 'plugins/informative/uptime'

bot = Cinch::Bot.new do
  configure do |c|
    c.nick            = $nick
    c.server          = "irc.freenode.net"
    c.port            = 6697
    c.verbose         = true
    c.channels        = ["#shakesoda"]
		c.realname        = "Questions? /msg Azure."
		c.user            = "AB2"
		#c.password        = "password"
		c.ssl.use         = true
		
		c.plugins.plugins = [
			Cinch::Plugins::BasicCTCP, 
			Cinch::Plugins::DownForEveryone, 
			Cinch::Plugins::Identify,
			
			Commands, Kickban, Toolbox, PrivToolbox,
			Attack, Decide, Dice, Dongs, Fb2kControl, Rainbow, Ryder,
			BotInfo, Booru, Twitter5, UrbanDictionary, Weather, QDB, Uptime
		]
		
		# Bot admins
		admins = %w{ azure }
		
		c.plugins.options[Twitter5] = YAML::load_file('D:\ircbot\twitter_oauth_config.yaml')
    c.plugins.options[Toolbox] = { :admins => admins }
    c.plugins.options[PrivToolbox] = { :admins => admins }
    c.plugins.options[BotInfo] = { :template => %q{D:\ircbot\info_template.txt}, :owner => admins[0] }
		
  end
end

bot.start