# -*- coding: UTF-8 -*-

#require_relative '../modules/authenticate'

module Plugins
  class Toolbox
    include Cinch::Plugin
    #include Authenticate

    set(
      plugin_name: "Toolbox", 
      help: "Bot administrator-only private commands.\nUsage: `~join [channel]`; `~part [channel] <reason>`; `~quit [reason]`; `~nick [newnick]`; `~opadmin`;", 
      prefix: /^~/)

    match /join (.+)/, method: :join
    def join(m, channel)
      return unless config[:admins].logged_in?(m.user.mask)
      channel.split(", ").each {|ch|
        Channel(ch).join
        @bot.handlers.dispatch :admin, m, "Attempt to join #{ch.split[0]} by #{m.user.nick}...", m.target
      }
    end

    match /part(?: (\S+)\s?(.+)?)?/, method: :part
    def part(m, channel, msg)
      return unless config[:admins].logged_in?(m.user.mask)
      channel ||= m.channel
      msg ||= m.user.nick
      Channel(channel).part(msg) if channel
      @bot.handlers.dispatch :admin, m, "Parted channel#{" - #{msg}" unless msg.nil?}", m.target
    end

    match /quit(?: (.+))?/, method: :quit
    def quit(m, msg)
      return unless config[:admins].logged_in?(m.user.mask)
  		msg ||= m.user.nick
      @bot.handlers.dispatch :admin, m, "I am going down for shutdown by #{m.user.nick} NOW!", m.target
      sleep 2
      bot.quit(msg)
    end

    match /nick (.+)/, method: :nick
  	def nick(m, nick)
  		return unless config[:admins].logged_in?(m.user.mask)
      botnick = @bot.nick.dup
  		bot.nick=(nick) if nick
      @bot.handlers.dispatch :admin, m, "My nick got changed from #{botnick} to #{@bot.nick} by #{m.user.nick}", m.target
  	end

    match /opadmin$/, method: :opadmin
    def opadmin(m)
  		return unless config[:admins].logged_in?(m.user.mask)
  		m.channel.op(m.user.nick);
      @bot.handlers.dispatch :admin, m, "I have opped #{m.user.nick}.", m.target
    end

    match /isupport$/, method: :isupport
    def isupport(m)
      return unless config[:admins].logged_in?(m.user.mask)
      m.user.notice ap(@bot.irc.isupport)
    end

  end
end