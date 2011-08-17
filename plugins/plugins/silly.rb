class Silly
	include Cinch::Plugin
	set(
		plugin_name: "silly",
		help: "You know, silly stuff.")
		
	match /\x01ACTION pokes (.+)\x01/i, method: :execute_poke, use_prefix: false
	def execute_poke m, poked
		if poked.casecmp(@bot.nick) == 0
			m.reply "Do NOT poke the bot!"
		end
	end

	match /dumb bot/i, method: :execute_botinsult, use_prefix: false
	def execute_botinsult m
		m.reply "Stupid human!"
	end

end