# -*- coding: UTF-8 -*-

# Give this bot ops in a channel and it'll auto voice visitors
#
# Enable with !autovoice on
# Disable with !autovoice off

module Plugins
  class AutoVoice
    include Cinch::Plugin
    
    set(
      plugin_name: "Auto Voice",
      help: "Automatically voices nicks upon join.\nUsage: `!autovoice [on|off]` -- turns autovoice on or off. (Admins only)",
      react_on: :channel)
    
    listen_to :join
    def listen(m)
      #@bot.debug("#{self.class.name} → #{config[:enabled_channels].inspect}");
      unless m.user.nick == bot.nick
        if config[:enabled_channels].include?(m.channel.name)
          sleep 0.5;
          m.user.refresh;
          return if ["v", "h", "o", "a", "q"].any? {|mode| m.channel.users[m.user].include?(mode)}
          m.channel.voice(m.user)
        end
      end
    end

    match /autovoice (on|off)$/
    def execute(m, option)
      begin
        return unless config[:admins].logged_in?(m.user.mask)
        
        @autovoice = option == "on"
        
        case option
          when "on"
            config[:enabled_channels] << m.channel.name
          else
            config[:enabled_channels].delete(m.channel.name)
        end
        
        m.reply "Autovoice for #{m.channel} is now #{@autovoice ? 'enabled' : 'disabled'}!"
        
        @bot.debug("#{self.class.name} → #{config[:enabled_channels].inspect}");
        
      rescue
        m.reply "Error: #{$!}"
      end
    end

  end
end