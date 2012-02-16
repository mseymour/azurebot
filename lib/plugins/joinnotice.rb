# -*- coding: utf-8 -*-

require 'active_support/core_ext/object/blank'

module Plugins
  class JoinNotice
    include Cinch::Plugin

    set plugin_name: "Auto Notice", help: "Notices nicks upon join.\nUsage: `!hello` to replay entry notice.", required_options: [:greetings, :filext]

    def get_channel_greeting channel
      open([config[:greetings], channel, config[:filext]].join, &:read) rescue nil
    end

    listen_to :join
    match "hello", method: :listen
    def listen m
      return if m.user.nick == @bot.nick
      greeting = get_channel_greeting(m.channel.name)
      return if greeting.blank?
      m.user.notice greeting.split($/).delete_if{|e| e.match(/^\/\//)}.map {|e| "[#{m.channel.name}] #{e.to_s}"}.join($/)
    end

  end
end
