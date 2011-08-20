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
      }
    end

    match /part(?: (\S+)\s?(.+)?)?/, method: :part
    def part(m, channel, msg)
      return unless config[:admins].logged_in?(m.user.mask)
      channel ||= m.channel
      msg ||= m.user.nick
      Channel(channel).part(msg) if channel
    end

    match /quit(?: (.+))?/, method: :quit
    def quit(m, msg)
      return unless config[:admins].logged_in?(m.user.mask)
  		msg ||= m.user.nick
      bot.quit(msg)
    end

    match /nick (.+)/, method: :nick
  	def nick(m, nick)
  		return unless config[:admins].logged_in?(m.user.mask)
  		bot.nick=(nick) if nick
  	end

    match /opadmin$/, method: :opadmin
    def opadmin(m)
  		return unless config[:admins].logged_in?(m.user.mask)
  		m.channel.op(m.user.nick);
    end

  end
end