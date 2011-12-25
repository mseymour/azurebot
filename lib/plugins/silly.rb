require 'active_support/time'
require 'active_support/core_ext/string'
require 'active_support/core_ext/object/blank'
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


    def tzparser tz
      prefix = (tz[0] !~ /(\+|-)/ ? "+" : "")
      suffix = (tz =~ /^(?:\+|-)?(\d{1,2})$/ ? ":00" : "")
      regexp = /^(\+|-)?(\d{1,2})(?::(\d{1,2}))?$/
      if tz =~ regexp
        prefix + tz.gsub(regexp) {|match| (!!$1 ? $1 : "") + $2.rjust(2,"0") + (!!$3 ? ":"+$3.rjust(2,"0") : "") } + suffix
      else
        raise ArgumentError, "A valid timezome was not supplied."
      end
    end

    match /xmas$/, method: :xmas
    match /xmas (\S+)/, method: :xmas
    def xmas (m, tz = nil)
      tz ||= "-00:00"
      tz = tzparser(tz)
      begin
        today = Time.now.localtime(tz)
        xmas = Time.new(today.year, 12, 25, 0, 0, 0, tz)
        xmas = xmas.next_year if xmas.to_date.past?
        message = if xmas.to_date == today.to_date
          "Merry Christmas!"
        else
          "There's #{time_diff_in_natural_language(today, xmas, seconds: false)} until Christmas!"
        end
      rescue ArgumentError => ae
        message = ae.message
      ensure
        m.reply message, true
      end
    end

  end
end
