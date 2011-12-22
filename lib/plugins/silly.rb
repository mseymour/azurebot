require 'active_support/time'
require 'active_support/core_ext/string'
require 'modules/stringhelpers'

module Plugins
	class Silly
		include Cinch::Plugin
    include StringHelpers
		set(
			plugin_name: "Silly",
			help: "You know, silly stuff.")
    
    _seconds_in_a_day = 86400

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

    match /\b(dumb|stupid)\b.+\bbot\b/i, method: :execute_botinsult, use_prefix: false
    def execute_botinsult (m); m.reply ["Stupid human!","Dumb human!","Stupid meatbag.","Silly human, your insults cannot harm me!"].sample if m.user.nick != "TempTina"; end

    match /xmas/, method: :xmas
    def xmas (m)
      today = Time.now
      xmas = Time.new(today.year,12,25)
      xmas = xmas.next_year if xmas.past?
      is_xmas = xmas.today?

      message = if is_xmas
        "Merry Christmas!"
      else
        "There's #{time_diff_in_natural_language(today,xmas, minutes: false, seconds: false)} until Christmas!"
      end

      m.reply message, true
    end

	end
end
