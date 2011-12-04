# -*- coding: UTF-8 -*-

require 'active_support/core_ext/object/blank'

module Plugins
  class JoinNotice
    include Cinch::Plugin
    
    set plugin_name: "Auto Notice", help: "Notices nicks upon join.\nUsage: `!hello` to replay entry notice.", required_options: [:greetings, :filext]
    
    def get_channel_greeting channel
      open([config[:greetings], channel, config[:filext]].join, &:read) rescue nil
    end
    
    listen_to :join
    match /hello$/, method: :listen
    def listen(m)
      return if m.user.nick == @bot.nick
      greeting = get_channel_greeting(m.channel.name)
      return if greeting.nil?
      notice = greeting.split("\n")
      notice.delete_if{|e| e.match(/^\/\//)} # Line is commented out.
      m.user.notice(notice.each_with_index.map {|element, index| 
        index_s = " | #{index+1}/#{notice.length}" if notice.length >= 2
        "[#{m.channel.name}#{index_s}] #{element}"
      }.join("\n")) unless notice.blank?
    end

  end
end
