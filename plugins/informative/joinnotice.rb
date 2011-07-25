# -*- coding: UTF-8 -*-

require 'active_support/core_ext'

class JoinNotice
  include Cinch::Plugin
  plugin "joinnotice"
  listen_to :join
  match /hello$/, method: :listen
  
  def get_channel_greeting channel
    open(config[:greetings] % { :channel => channel }, &:read) rescue nil
  end
  
  def listen(m)
    unless m.user.nick == bot.nick
      notice = get_channel_greeting m.channel.name
      if !notice.blank?
        m.user.notice(notice)
      end
    end
  end

end