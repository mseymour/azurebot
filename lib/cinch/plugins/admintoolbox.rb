# -*- coding: utf-8 -*-

require_relative "../admin"

module Cinch
  module Plugins
    class AdminToolbox
      include Cinch::Plugin
      include Cinch::Admin

      set(
        plugin_name: "Private Administrator toolbox",
        help: "Bot administrator-only private commands.\nUsage: n/a",
        react_on: :private,
        prefix: /^/)

      # Admins

      match "setup admin access", method: :execute_setup_admin
      def execute_setup_admin(m)
        return unless no_admins?
        mask = m.user.mask("*!*@%h")
        add_admin(mask)
        m.reply "Welcome, #{m.user.nick}!"
        m.reply "Added admin #{mask} to network #{@bot.irc.isupport['NETWORK']}."
        @bot.handlers.dispatch :admin, m, "#{m.user.nick} just added #{mask} to Admins.", m.target
      end

      match /add admin (.+)/, method: :execute_add_admin
      def execute_add_admin(m, mask)
        return unless is_admin?(m.user)
        add_admin(mask)
        m.reply "Added admin #{mask} to network #{@bot.irc.isupport['NETWORK']}."
        @bot.handlers.dispatch :admin, m, "#{m.user.nick} just added #{mask} to Admins.", m.target
      end

      match /del admin (.+)/, method: :execute_del_admin
      def execute_del_admin(m, mask)
        return unless is_admin?(m.user)
        delete_admin(mask)
        m.reply "Deleted #{mask} from network #{@bot.irc.isupport['NETWORK']}."
        @bot.handlers.dispatch :admin, m, "#{m.user.nick} just deleted #{mask} from Admins.", m.target
      end

      match 'list admins', method: :execute_list_admins
      def execute_list_admins(m)
        return unless is_admin?(m.user)
        m.reply "Administrators on %s:\n%s" % [@bot.irc.isupport['NETWORK'], get_admins.join("\n")]
      end

      # Trusted

      match /add trusted (.+)/, method: :execute_add_trusted
      def execute_add_trusted(m, mask)
        return unless is_admin?(m.user)
        add_trusted(mask)
        m.reply "Added trusted #{mask} to network #{@bot.irc.isupport['NETWORK']}."
        @bot.handlers.dispatch :admin, m, "#{m.user.nick} just added #{mask} to Trusted.", m.target
      end

      match /del trusted (.+)/, method: :execute_del_trusted
      def execute_del_trusted(m, mask)
        return unless is_admin?(m.user)
        delete_trusted(mask)
        m.reply "Deleted trusted #{mask} from network #{@bot.irc.isupport['NETWORK']}."
        @bot.handlers.dispatch :admin, m, "#{m.user.nick} just deleted #{mask} from Trusted.", m.target
      end

      match 'list trusted', method: :execute_list_trusted
      def execute_list_trusted(m)
        return unless is_admin?(m.user)
        m.reply "Trusted on %s:\n%s" % [@bot.irc.isupport['NETWORK'], get_trusted.join("\n")]
      end

    end
  end
end
