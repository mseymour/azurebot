# coding: utf-8
require_relative '../helpers/check_user'
require 'active_support/time'
require 'chronic_duration'

module Cinch
  module Plugins
    class TimeBan
      include Cinch::Plugin

      attr_reader :active_timebans

      set plugin_name: 'Timeban',
          help: 'help'

      TIMEBAN_KEY = 'timeban:%s:%s:%s' # network, channel.name.downcase, nick.downcase

      def initialize(*args)
        super
        @active_timebans = Hash.new {|hash, key| hash[key] = {} }
      end

      match /timeban (\S+) ((?:\d+\w)+)(?: (.+))?/, method: :execute_timeban
      def execute_timeban(m, nick, range, reason)
        return m.user.notice('#{Format(:red,:bold,"Whoops!")} · I do not have the correct privileges. (not +%s)' % @bot.irc.isupport["PREFIX"].keys - ['v']) unless check_user(m.channel, @bot)
        return m.user.notice('#{Format(:red,:bold,"Whoops!")} · You do not have the correct privileges. (not +%s)' % @bot.irc.isupport["PREFIX"].keys - ['v']) unless check_user(m.channel, m.user)
        user = User(nick)
        return if user == @bot
        return m.user.notice('%s does not seem to exist on %s' % [nick, @bot.irc.network.name]) if user.unknown?
        key = TIMEBAN_KEY % [@bot.irc.isupport['NETWORK'], m.channel.name.downcase, user.nick.downcase]
        set = key[/(.+):\S+$/,1]

        now = Time.now
        
        bandata = {
          'nick' => user.nick,
          'host.mask' => user.mask('*!*@%h'),
          'ban.start' => now,
          'ban.end' => range2time(range, now),
          'ban.reason' => reason || 'fuck you!',
          'banned.by' => m.user.mask
        }
        
        # Only add timeban entries that are less than a year in length
        if range2h(range)[:years] < 1
          synchronize(:timeban_update) do
            shared[:redis].hmset key, *bandata
            shared[:redis].sadd set, key
            @active_timebans[m.channel.name.downcase][user.nick.downcase] = 
              Timer(bandata['ban.end'] - Time.now, shots: 1) { unban(m, key) }
          end
          @bot.handlers.dispatch :timeban, m, 
            "%s just set a timed ban in %s for %s (%s) with reason %s. (Lasts %s.)" % [
              m.user.nick, 
              m.channel.name, 
              bandata['nick'], 
              bandata['host.mask'], 
              bandata['ban.reason'], 
              ChronicDuration.output((bandata['ban.end'] - bandata['ban.start']).round, format: :long)
            ], m.target
        else
          @bot.handlers.dispatch :timeban, m, 
            "%s just set a permanent (un)timed ban in %s for %s (%s) with reason %s." % [
              m.user.nick, 
              m.channel.name, 
              bandata['nick'], 
              bandata['host.mask'], 
              bandata['ban.reason']
            ], m.target
        end

        kickreason = 'Banned for %s by %s (%s)' % [ 
          ChronicDuration.output((bandata['ban.end'] - bandata['ban.start']).round, format: :long), 
          m.user.nick, 
          bandata['ban.reason']
        ]

        m.channel.ban(bandata['host.mask'])
        m.channel.kick(user, kickreason)

        # @todo kick all other nicks with the same host
      end

      match /unban (\S+)$/, method: :execute_unban
      def execute_unban(m, nick)
        return m.user.notice('#{Format(:red,:bold,"Whoops!")} · I do not have the correct privileges. (not +%s)' % @bot.irc.isupport["PREFIX"].keys - ['v']) unless check_user(m.channel, @bot)
        return m.user.notice('#{Format(:red,:bold,"Whoops!")} · You do not have the correct privileges. (not +%s)' % @bot.irc.isupport["PREFIX"].keys - ['v']) unless check_user(m.channel, m.user)

        key = TIMEBAN_KEY % [@bot.irc.isupport['NETWORK'], m.channel.name.downcase, nick.downcase]

        if shared[:redis].exists(key)
          bandata = shared[:redis].hgetall(key)
          unban(m, key)
        else
          m.user.notice("#{Format(:red,:bold,"Whoops!")} · No timed ban could be found for %s." % nick)
        end
      end

      match 'listbans', method: :execute_listbans
      def execute_listbans(m)
        return m.user.notice("#{Format(:red,:bold,"Whoops!")} · You don't have the proper authorization for that.") unless check_user(m.channel, m.user)
        key = TIMEBAN_KEY % [@bot.irc.isupport['NETWORK'], m.channel.name.downcase, nil]
        bans = shared[:redis].smembers(key[0..-2]).each_with_object([]) {|timeban,memo| memo << shared[:redis].hgetall(timeban) }
        lines = bans.each_with_index.each_with_object([]) {|(timeban,i),memo|
          width = timeban.keys.max_by(&:length).length
          memo << timeban.each_with_object([]) {|(k,v),mem| mem << "%-#{width}s: %s" % [k,v] }
        }
        if lines.length > 0
          maxwidth = lines.flatten.max_by {|l| l.length }.length
          lines.each_with_index {|l,i|
            m.user.msg ("#%d " % i.succ).ljust(maxwidth, '-')
            m.user.msg l * $/
          }
          m.user.msg '* End of results.'
        else
          m.user.msg "#{Format(:red,:bold,"Whoops!")} · No timebans could be found for %s." % m.channel.name
        end
      end

      listen_to :join, method: :on_join
      def on_join(m)
        return unless m.user == @bot
        key = TIMEBAN_KEY % [@bot.irc.isupport['NETWORK'], m.channel.name.downcase, nil]
        if shared[:redis].exists(key[0..-2])
          sleep 4
          shared[:redis].smembers(key[0..-2]).each {|timeban|
            bandata = shared[:redis].hgetall(timeban)
            if Time.parse(bandata['ban.end']) > Time.now
              @active_timebans[m.channel.name.downcase][bandata['nick'].downcase] = 
              Timer(Time.parse(bandata['ban.end']) - Time.now, shots: 1) { unban(m, timeban) }
            else
              unban(m, timeban)
            end
          }
        end
      end

      listen_to :part, method: :on_part
      def on_part(m)
        return unless m.user == @bot
        channel_name = m.channel.name.downcase
        @active_timebans[channel_name].each {|_, timer| timer.stop }
        @active_timebans.delete(channel_name)
      end

      #listen_to :unban, method: :on_unban
      #def on_unban(m, mask)
        #return if m.user == @bot
        # @todo Re-arm ban
      #end

      private

      # Converts a string range to a time in the future.
      # Valid range characters are `yMwdhms`
      # @param [String] s A string in the format `dX[dX...]` where `d` is a number and `x` is a letter. (see above.)
      # @param [Time] t (nil) A +Time+ object.
      def range2time(s, t=nil)
        t ||= Time.now
        t.utc.advance range2h(s)
      end

      # Splits a timeban range into a hash.
      def range2h(s)
        range = s.scan(/\d+\w/).each_with_object(Hash.new(0)) {|time, memo| memo[time[-1]] += time[0..-2].to_i }
        Hash[[:years, :months, :weeks, :days, :hours, :minutes, :seconds].zip(range.values_at(*%w{y M w d h m s}))]
      end

      # Unbans a user from a specified channel and deletes the record.
      # @param [Message] m A +Message+ object from the calling method.
      # @param [String] key A String that is the key for the stored hash
      def unban(m, key)
        m.channel.unban(shared[:redis].hget(key, 'host.mask'))
        dispatch_unban_handler(m, shared[:redis].hgetall(key))
        shared[:redis].del key # remove hash from redis
        shared[:redis].srem key[/(.+):\S+$/,1], key # remove key from set
        if @active_timebans[m.channel.name.downcase].member?(key[/.+:(\S+)$/,1])
          @active_timebans[m.channel.name.downcase][key[/.+:(\S+)$/,1]].stop # stop timer
          @active_timebans[m.channel.name.downcase].delete key[/.+:(\S+)$/,1] # delete timer
        end
      end

      def dispatch_unban_handler(m, bandata)
        @bot.handlers.dispatch :timeban, m, 
          "%s (%s) was just unbanned from %s. (banned by %s; reason was \"%s\"; lasted %s.)" % [
            bandata['nick'], 
            bandata['host.mask'],
            m.channel.name,  
            bandata['banned.by'],
            bandata['ban.reason'], 
            ChronicDuration.output((Time.parse(bandata['ban.end']) - Time.parse(bandata['ban.start'])).round, format: :long)
          ], m.target
        end

    end
  end
end
