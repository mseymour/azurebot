# -*- coding: utf-8 -*-

module Plugins
  class PrivToolbox
    include Cinch::Plugin
    #include Authenticate

    set(
      plugin_name: "Private toolbox",
      help: "Bot administrator-only private commands.\nUsage: n/a",
      required_options: [:admins],
      react_on: :private)

    match %r{^say (#\S+) (.+)}, method: :say, use_prefix: false
    def say(m, channel, text)
      return unless config[:admins].logged_in?(m.user.mask)
      Channel(channel).send(text)
      @bot.handlers.dispatch :private_admin, m, "said in #{channel}: #{text}", m.target
    end

    match %r{^act (#\S+) (.+)}, method: :act, use_prefix: false
    def act(m, channel, text)
      return unless config[:admins].logged_in?(m.user.mask)
      Channel(channel).action(text)
      @bot.handlers.dispatch :private_admin, m, "acted in #{channel}: #{text}", m.target
    end

    match %r{^cs (.+)}, method: :cs, use_prefix: false
    def cs(m, text)
      return unless config[:admins].logged_in?(m.user.mask)
      User("chanserv").send(text)
      @bot.handlers.dispatch :private_admin, m, "chanserv: #{text}", m.target
    end

    match %r{^ns (.+)}, method: :ns, use_prefix: false
    def ns(m, text)
      return unless config[:admins].logged_in?(m.user.mask)
      User("nickserv").send(text)
      @bot.handlers.dispatch :private_admin, m, "nickserv: #{text}", m.target
    end

    match %r{^hs (.+)}, method: :hs, use_prefix: false
    def hs(m, text)
      return unless config[:admins].logged_in?(m.user.mask)
      User("hostserv").send(text)
      @bot.handlers.dispatch :private_admin, m, "hostserv: #{text}", m.target
    end

    match %r{^psa (.+)}, method: :psa, use_prefix: false
    def psa(m, text)
      return unless config[:admins].logged_in?(m.user.mask)
      @bot.channels.each {|channel|
        channel.safe_notice "[#{m.user.nick}] #{text}"
      }
      @bot.handlers.dispatch :private_admin, m, "Public service announcement: #{text}", m.target
    end

    # Channel kicks etc.

    match %r{^kick (#\S+) (\S+)\s?(.+)?}, method: :kick, use_prefix: false
    def kick(m, channel, user, msg)
      return unless config[:admins].logged_in?(m.user.mask)
      msg ||= m.user.nick
      channel = Channel(channel)
      user = User(user)
      channel.kick(user, msg)
      @bot.handlers.dispatch :admin, m, "Kicked #{user.nick} from #{channel.name}#{" - \"#{msg}\"" unless msg.nil?}", m.target
    end

    match %r{^ban (#\S+) (\S+)}, method: :ban, use_prefix: false
    def ban(m, channel, user)
      return unless config[:admins].logged_in?(m.user.mask)
      channel = Channel(channel)
      user = User(user)
      mask = user.mask("*!*@%h")
      channel.ban(mask)
      @bot.handlers.dispatch :admin, m, "Banned #{user.nick} (#{mask.to_s}) from #{channel.name}", m.target
    end

    match %r{^unban (#\S+) (\S+)}, method: :unban, use_prefix: false
    def unban(m, channel, mask)
      return unless config[:admins].logged_in?(m.user.mask)
      channel = Channel(channel)
      channel.unban(mask)
      @bot.handlers.dispatch :admin, m, "Unbanned #{mask} from #{channel.name}", m.target
    end

    match %r{^kb (#\S+) (\S+)\s?(.+)?}, method: :kickban, use_prefix: false
    def kickban(m, channel, user, msg)
      return unless config[:admins].logged_in?(m.user.mask)
      msg ||= m.user.nick
      channel = Channel(channel)
      user = User(user)
      mask = user.mask("*!*@%h")
      channel.ban(mask)
      channel.kick(user, msg)
      @bot.handlers.dispatch :admin, m, "Kickbanned #{user} (#{mask.to_s}) from #{channel.name}#{" - \"#{msg}\"" unless msg.nil?}", m.target
    end

  end
end
