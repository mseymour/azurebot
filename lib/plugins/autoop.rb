# -*- coding: utf-8 -*-

# Give this bot ops in a channel and it'll auto op visitors
#
# Enable with !autoop on
# Disable with !autoop off

module Plugins
  class AutoOP
    include Cinch::Plugin

    set(
      plugin_name: "Auto OP",
      help: "Automatically ops nicks upon join.\nUsage: `!autoop [on|off]` -- turns autoop on or off. (Admins only)",
      reacting_on: :channel)

    listen_to :join
    def listen(m)
      #@bot.debug("#{self.class.name} → #{config[:enabled_channels].inspect}");
      unless m.user.nick == bot.nick
        if config[:enabled_channels].include?(m.channel.name)
          sleep 0.5;
          m.user.refresh;
          return if ["v", "h", "o", "a", "q"].any? {|mode| m.channel.users[m.user].include?(mode)}
          m.channel.op(m.user)
        end
      end
    end

    match /autoop (on|off)$/
    def execute(m, option)
      begin
        return unless config[:admins].logged_in?(m.user.mask)

        @autoop = option == "on"

        case option
          when "on"
            config[:enabled_channels] << m.channel.name
          else
            config[:enabled_channels].delete(m.channel.name)
        end

        m.reply "AutoOP for #{m.channel} is now #{@autoop ? 'enabled' : 'disabled'}!"

        @bot.debug("#{self.class.name} → #{config[:enabled_channels].inspect}");

      rescue
        m.reply "Error: #{$!}"
      end
    end
  end
end
