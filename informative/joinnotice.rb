# -*- coding: UTF-8 -*-

require 'cinch'

class JoinNotice
  include Cinch::Plugin
  plugin "joinnotice"
  listen_to :join
  
  def listen(m)
    if config[:greetings].include?(m.channel.name)
      unless m.user.nick == bot.nick
        m.user.notice(open(config[:greetings][m.channel.name], &:read))
      end
    end
  end

end