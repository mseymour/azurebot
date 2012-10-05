# -*- coding: utf-8 -*-

require_relative "../admin"

module Cinch
  module Plugins
    class Toolbox
      include Cinch::Plugin
      include Cinch::Admin

      set(
        plugin_name: "Toolbox",
        help: "Bot administrator-only private commands.\nUsage: `~join [channel]`; `~part [channel] <reason>`; `~quit [reason]`; `~nick [newnick]`; `~opadmin`;",
        prefix: /^~/)

      def initialize(*args)
        super
        Kernel.trap('INT') { @bot.quit("assimilated into the borg.") }
      end

      match /join (.+)/, method: :join
      def join(m, channel)
        return unless is_admin?(m.user)
        channel.split(", ").each {|ch|
          Channel(ch).join
          @bot.handlers.dispatch :admin, m, "Attempt to join #{ch.split[0]} by #{m.user.nick}...", m.target
        }
      end

      match /part(?: (\S+))?(?: (.+))?/, method: :part, group: :part
      def part(m, channel=nil, msg=nil)
        return unless is_admin?(m.user)
        channel ||= m.channel.name
        msg ||= m.user.nick
        Channel(channel).part(msg) if channel
        @bot.handlers.dispatch :admin, m, "Parted #{channel}#{" - #{msg}" unless msg.nil?}", m.target
      end

      match /quit(?: (.+))?/, method: :quit, group: :quit
      def quit(m, msg=nil)
        return unless is_admin?(m.user)
        msg ||= m.user.nick
        @bot.handlers.dispatch :admin, m, "I am being shut down NOW!#{" - Reason: " + msg unless msg.nil?}", m.target
        sleep 2
        bot.quit(msg)
      end

      match /nick (.+)/, method: :nick
      def nick(m, nick)
        return unless is_admin?(m.user)
        botnick = @bot.nick.clone
        bot.nick = nick
        @bot.handlers.dispatch :admin, m, "My nick got changed from #{botnick} to #{@bot.nick} by #{m.user.nick}", m.target
      end

      match /eval (.+)/, method: :boteval
      def boteval(m, s)
        return unless is_admin?(m.user)
        eval(s)
      rescue => e
        m.user.msg "eval error: %s\n- %s (%s)" % [s, e.message, e.class.name]
      end

    end
  end
end
