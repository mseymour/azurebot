module Plugins
	class DelayedRejoin
		include Cinch::Plugin

		set plugin_name: "Delayed Rejoin", help: "If the bot is kicked, it will attempt to rejoin after 10 seconds by default."

		listen_to :kick
		def listen m
			return unless m.params[1] == @bot.nick
			sleep config[:delay] || 10
			Channel(m.channel.name).join(m.channel.key)
		end
	end
end