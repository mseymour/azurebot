require 'active_support/time'
require 'active_support/core_ext/string'
require 'active_support/core_ext/object/blank'
require_relative '../helpers/natural_language'
require 'date'

module Cinch
  module Plugins
    class Silly
      include Cinch::Plugin
      include Cinch::Helpers::NaturalLanguage
      set(
        plugin_name: "Silly",
        help: "You know, silly stuff.")

      _seconds_in_a_day = 86400

      attr_reader :pokers

      def initialize *args
        super
        @pokers = {}
      end

      match /^pokes (.+)$/, react_on: :action, method: :listen_poke, use_prefix: false
      def listen_poke(m, thebot)
        if User(thebot) == @bot
          @pokers[m.user] = 0 if !@pokers.include?(m.user)
          @pokers[m.user] += 1
          case @pokers[m.user]
          when 1..3
            m.reply "Do NOT poke the bot!"
          when 4
            m.reply "I said, do NOT poke the bot!"
          when 5
            m.channel.kick m.user, ["WHAT ARE YOU, AN IDIOT? I SAID DO NOT POKE ME!!","THIS! IS! SPARTA!!"].sample
            @pokers.delete(m.user)
          end
        end
      end

      match /\b(dumb|stupid)\b.+\bbots*\b/i, method: :execute_botinsult, use_prefix: false
      def execute_botinsult(m); m.reply ["Stupid human!","Dumb human!","Stupid meatbag.","Silly human, your insults cannot harm me!"].sample if m.user.nick != "TempTina"; end

      def tzparser(tz)
        prefix = (tz[0] !~ /(\+|-)/ ? "+" : "")
        suffix = (tz =~ /^(?:\+|-)?(\d{1,2})$/ ? ":00" : "")
        regexp = /^(\+|-)?(\d{1,2})(?::(\d{1,2}))?$/
        if tz =~ regexp
          prefix + tz.gsub(regexp) {|match| (!!$1 ? $1 : "") + $2.rjust(2,"0") + (!!$3 ? ":"+$3.rjust(2,"0") : "") } + suffix
        else
          raise ArgumentError, "A valid timezome was not supplied."
        end
      end

      match "xmas", method: :xmas
      match /xmas (\S+)/, method: :xmas
      def xmas(m, tz = nil)
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

      match "newyear", method: :newyear
      match /newyear (\S+)/, method: :newyear
      def newyear(m, tz = nil)
        tz ||= "-00:00"
        tz = tzparser(tz)
        begin
          today = Time.now.localtime(tz)
          nyear = Time.new(today.year.succ, 1, 1, 0, 0, 0, tz)
          #nyear = nyear.next_year if nyear.to_date.past?
          message = if nyear.to_date == today.to_date
            "Happy New Year #{today.year}!"
          else
            "There's #{time_diff_in_natural_language(today, nyear)} until #{nyear.year}!"
          end
        rescue ArgumentError => ae
          message = ae.message
        ensure
          m.reply message, true
        end
      end

      match "tz", method: :tz
      match /tz (\S+)/, method: :tz
      def tz(m, tz = nil)
        tz ||= "-00:00"
        tz = tzparser(tz)
        begin
          today = Time.now.localtime(tz)
          message = today.to_s
        rescue ArgumentError => ae
          message = ae.message
        ensure
          m.reply message, true
        end
      end

      match "mayan", method: :mayan
      def mayan(m)
        msd = (Date.today.jd - Date.new(1,1,1).jd) + 1137142
        lc = {
          baktun: (msd - (msd % 144000)) / 144000,
          katun:  ((msd - (msd % 7200)) / 7200) % 20,
          tun:    ((msd - (msd % 360)) / 360) % 20,
          uinal:  ((msd - (msd % 20)) / 20) % 18,
          kin:    (msd % 20)
        }

        m.reply "#{lc[:baktun]}.#{lc[:katun]}.#{lc[:tun]}.#{lc[:uinal]}.#{lc[:kin]}"
      end

    end
  end
end