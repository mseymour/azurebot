# -*- coding: UTF-8 -*-

require 'cinch'
require_relative '../../modules/authenticate'

# Give this bot ops in a channel and it'll auto op
# visitors
#
# Enable with !autoop on
# Disable with !autoop off

class JoinGreet
  include Cinch::Plugin
  include Authenticate
  plugin "autogreet"
  listen_to :join
  help "autogreet (on|off) -- turns autoop on or off."
  match /autogreet (on|off)$/
  
  #def initialize(*args)
    #super
    #config[:enabled_channels] = []
    #@admins = ["Georgette_Lemare", "Helma01", "Kanata", "BlackRose", "Lain", "Lain|the-wiredless", "azure"]
  #end

  def listen(m)
    unless m.user.nick == bot.nick
      if config[:enabled_channels].include?(m.channel.name)
        m.user.notice(greeting(m.user.nick))
      end
    end
  end

  def greeting( nick=nil )
    case Time.now.hour
      when 0..4, 18..23
        "Good evening" + (!nick.nil? ? ", #{nick}" : "") + "."
      when 5..11
        "Good morning" + (!nick.nil? ? ", #{nick}" : "") + "."
      when 12..17
        "Good afternoon" + (!nick.nil? ? ", #{nick}" : "") + "."
    end
  end

  def execute(m, option)
    begin
      return unless Auth::is_admin?(m.user)
      if m.channel.nil? then raise("This is not a channel!") end
    
      @autogreet = option == "on"
      
      case option
        when "on"
          config[:enabled_channels] << m.channel.name
        else
          config[:enabled_channels].delete(m.channel.name)
      end
      
      m.reply "Automatic greetings for #{m.channel} is now #{@autogreet ? 'enabled' : 'disabled'}!"
      
      @bot.debug("#{self.class.name} → #{config[:enabled_channels].inspect}");
      
    rescue
      m.reply "Error: #{$!}"
    end
  end
end