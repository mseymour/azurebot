# -*- coding: UTF-8 -*-

require 'cinch'
require_relative '../../modules/authenticate'

# Give this bot ops in a channel and it'll auto op visitors
#
# Enable with !autoop on
# Disable with !autoop off

class AutoOP
  include Cinch::Plugin
  include Authenticate
  
  plugin "autoop"
  listen_to :join
  react_on :channel
  help "autoop (on|off) -- turns autoop on or off."
  match /autoop (on|off)$/
  
  def listen(m)
    #@bot.debug("#{self.class.name} → #{config[:enabled_channels].inspect}");
    unless m.user.nick == bot.nick
      if config[:enabled_channels].include?(m.channel.name)
        m.channel.op(m.user)
      end
    end
  end

  def execute(m, option)
    begin
      return unless Auth::is_admin?(m.user)
      
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