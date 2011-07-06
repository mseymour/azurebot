# -*- coding: UTF-8 -*-

require 'cinch'
require_relative '../_ext/blank.rb'

class JoinNotice
  include Cinch::Plugin
  plugin "joinnotice"
  listen_to :join
  
  def listen(m)
    unless m.user.nick == bot.nick
      notice = open(config[:greetings] % { :channel => m.channel.name }, &:read) rescue nil
      if !notice.blank?
        m.user.notice(notice)
      end
    end
  end

end