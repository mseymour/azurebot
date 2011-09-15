module Plugins
	class Silly
		include Cinch::Plugin
		set(
			plugin_name: "silly",
			help: "You know, silly stuff.")
			
		match /\x01ACTION pokes (\S+)\x01/i, method: :execute_poke, use_prefix: false
		def execute_poke m, poked
			if poked.casecmp(@bot.nick) == 0
				m.reply "Do NOT poke the bot!"
			end
		end

		match /dumb bot/i, method: :execute_botinsult, use_prefix: false
		def execute_botinsult (m); m.reply ["Stupid human!","Dumb human!","Stupid meatbag."].sample if m.user.nick != "TempTina"; end; #somehow make a bot-wide nick ignore list.

    #match /\x01ACTION (?:.*)\b(\S+)\b(?:.*)\x01/i, method: :execute_donk, use_prefix: false
    match /\x01ACTION (?:.*)\bdonk\b(?:.*)\x01/i, method: :execute_donk, use_prefix: false
    def execute_donk (m); m.reply ["Put a banging donk on it!","You know what you wanna do with that right?"].sample end; #somehow make a bot-wide nick ignore list.

    match /\bbangin(?:'|g) donk on (\S+)\b/i, method: :execute_donking, use_prefix: false
    match /\x01ACTION donks (\S+)\x01/i, method: :execute_donking, use_prefix: false
    def execute_donking m, donked
      if donked.casecmp(@bot.nick) == 0
        sleep 1
        m.reply "..."
        sleep 30
        m.reply "PUT A BANGING DONK ON ME!"
      end
    end

	end
end