module Plugins
	class Silly
		include Cinch::Plugin
		set(
			plugin_name: "silly",
			help: "You know, silly stuff.")
    
    def action_match ctcp_args, match, compare = true
      if compare
        !!(ctcp_args.join(" ") =~ match) if ctcp_args.is_a?(Array) && match.is_a?(Regexp)
      else 
        ctcp_args.join(" ").match(match) if ctcp_args.is_a?(Array) && match.is_a?(Regexp)
      end
    end

    listen_to :action, method: :listen_poke
    def listen_poke m
      return unless action_match(m.ctcp_args, %r{^pokes (\S+)})
      if action_match(m.ctcp_args, %r{^pokes (\S+)}, false)[1].casecmp(@bot.nick) == 0
        m.reply "Do NOT poke the bot!"
      end
    end

    match /dumb bot/i, method: :execute_botinsult, use_prefix: false
    def execute_botinsult (m); m.reply ["Stupid human!","Dumb human!","Stupid meatbag."].sample if m.user.nick != "TempTina"; end

	end
end