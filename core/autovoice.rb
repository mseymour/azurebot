# -*- coding: UTF-8 -*-

require 'cinch'

# Give this bot ops in a channel and it'll auto voice visitors
#
# Enable with !autovoice on
# Disable with !autovoice off

class Autovoice
  include Cinch::Plugin
  plugin "autovoice"
  listen_to :join
  react_on :channel
  help "autovoice (on|off) -- turns autovoice on or off."
  match /autovoice (on|off)$/

  def check_user(user)
    user.refresh # be sure to refresh the data, or someone could steal the nick
    config[:admins].include?(user.authname)
  end
  
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

  def execute(m, option)
    begin
      return unless check_user(m.user)
      
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