# -*- coding: utf-8 -*-

require_relative "../admin"

module Cinch
  module Plugins
    class PrivToolbox
      include Cinch::Plugin
      include Cinch::Admin

      set(
        plugin_name: "Private toolbox",
        help: "Bot administrator-only private commands.\nUsage: n/a",
        react_on: :private,
        prefix: /^/)

      match /say (#\S+) (.+)/, method: :say
      def say(m, channel, text)
        return unless is_trusted?(m.user)
        Channel(channel).send(text)
        @bot.handlers.dispatch :private_admin, m, "said in #{channel}: #{text}", m.target
      end

      match /msg (\S+) (.+)/, method: :msg
      def msg(m, user, text)
        return unless is_trusted?(m.user)
        User(user).send(text)
        @bot.handlers.dispatch :private_admin, m, "said to #{user}: #{text}", m.target
      end


      match /act (#\S+) (.+)/, method: :act
      def act(m, channel, text)
        return unless is_trusted?(m.user)
        Channel(channel).action(text)
        @bot.handlers.dispatch :private_admin, m, "acted in #{channel}: #{text}", m.target
      end

      match /cs (.+)/, method: :cs
      def cs(m, text)
        return unless is_admin?(m.user)
        User("chanserv").send(text)
        @bot.handlers.dispatch :private_admin, m, "chanserv: #{text}", m.target
      end

      match /ns (.+)/, method: :ns
      def ns(m, text)
        return unless is_admin?(m.user)
        User("nickserv").send(text)
        @bot.handlers.dispatch :private_admin, m, "nickserv: #{text}", m.target
      end

      match /hs (.+)/, method: :hs
      def hs(m, text)
        return unless is_admin?(m.user)
        User("hostserv").send(text)
        @bot.handlers.dispatch :private_admin, m, "hostserv: #{text}", m.target
      end

      match /psa (.+)/, method: :psa
      def psa(m, text)
        return unless is_admin?(m.user)
        @bot.channels.each {|channel|
          channel.safe_notice "[#{m.user.nick}] #{text}"
        }
        @bot.handlers.dispatch :admin, m, "Public service announcement: #{text}", m.target
      end

      # Channel kicks etc.

      match /kick (#\S+) (\S+)\s?(.+)?/, method: :kick
      def kick(m, channel, user, msg)
        return unless is_trusted?(m.user)
        msg ||= m.user.nick
        channel = Channel(channel)
        user = User(user)
        channel.kick(user, msg)
        @bot.handlers.dispatch :admin, m, "Kicked #{user.nick} from #{channel.name}#{" - \"#{msg}\"" unless msg.nil?}", m.target
      end

      match /ban (#\S+) (\S+)/, method: :ban
      def ban(m, channel, user)
        return unless is_trusted?(m.user)
        channel = Channel(channel)
        user = User(user)
        mask = user.mask("*!*@%h")
        channel.ban(mask)
        @bot.handlers.dispatch :admin, m, "Banned #{user.nick} (#{mask.to_s}) from #{channel.name}", m.target
      end

      match /unban (#\S+) (\S+)/, method: :unban
      def unban(m, channel, mask)
        return unless is_trusted?(m.user)
        channel = Channel(channel)
        channel.unban(mask)
        @bot.handlers.dispatch :admin, m, "Unbanned #{mask} from #{channel.name}", m.target
      end

      match /kb (#\S+) (\S+)\s?(.+)?/, method: :kickban
      def kickban(m, channel, user, msg)
        return unless is_trusted?(m.user)
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
end