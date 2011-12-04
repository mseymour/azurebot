require 'date'

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

    match /xmas/, method: :xmas
    def xmas (m)
      today = Date.today
      xmas = Date.new(today.year,12,25)
      xmas = xmas.next_year if (xmas <=> today) == -1
      days_until_xmas = (xmas - today).to_i

      def sinplur (num, singular, plural); num != 1 ? plural : singular; end;

      m.reply((today == xmas ? "Merry Christmas, #{m.user.nick}!" : "There #{sinplur(days_until_xmas,"is","are")} #{days_until_xmas} #{sinplur(days_until_xmas,"more day","days")} until Christmas!"))
    end

	end
end