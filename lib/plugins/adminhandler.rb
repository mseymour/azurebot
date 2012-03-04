# -*- coding: utf-8 -*-
require_relative '../modules/helpers/table_format'

module Plugins
  class AdminHandler
    include Cinch::Plugin

    set(
      plugin_name: "Admin",
      help: "Admin handler -- handles admins, of course.",
      required_options: [:admins],
      reacting_on: :private,
      prefix: /^/)

    def login(m, user, password)
      return "You are already here, #{user.nick}." unless !config[:admins].logged_in? user.mask
      result = config[:admins].login! user.mask, password
      if result
        @bot.handlers.dispatch :admin, m, "#{user.nick} has been successfully logged in.", user
        "Welcome back, #{user.nick}."
      else
        @bot.handlers.dispatch :admin, m, "#{user.nick} tried to login but failed.", user
        "#{user.nick}, your password is incorrect."
      end
    end

    match /login (.+)/, method: :execute_login
    def execute_login(m, password)
      m.user.msg login(m, m.user, password), true
    end

    match "logout", method: :execute_logout
    def execute_logout(m)
      return unless config[:admins].logged_in? m.user.mask
      config[:admins].logout! m.user.mask
      m.user.msg "Sayonara, #{m.user.nick}.", true
      @bot.handlers.dispatch :admin, m, "#{user.nick} has successfully logged out.", m.target
    end

    match "flogout", method: :execute_flogout
    def execute_flogout(m)
      return unless config[:admins].logged_in? m.user.mask
      hosts = []
      config[:admins].each_admin {|host|
        config[:admins].logout! host
        m.user.msg "Sayonara, #{m.user.nick}.", true
        @bot.handlers.dispatch :admin, m, "#{host.match(/(.+)!(.+)@(.+)/)[1]} has successfully logged out by #{m.user.nick}.", m.target
      }
    end

    match "list admins", method: :execute_admins
    def execute_admins(m)
      return unless config[:admins].logged_in? m.user.mask
      m.user.msg Helpers::table_format(config[:admins].masks, regexp: /(?:(.+)!)?(.+)/, gutter: 1, justify: [:right,:left], headers: ["nick","username+host"]), true
    end

    listen_to :nick, method: :listen_nick
    def listen_nick(m)
      return unless config[:admins].logged_in?(m.user.mask("#{m.user.last_nick}!%u@%h"))
      config[:admins].update m.user.mask("#{m.user.last_nick}!%u@%h"), m.user.mask
      @bot.debug "Updated hostmask. (`#{m.user.mask("#{m.user.last_nick}!%u@%h")}` -> `#{m.user.mask}`)"
      @bot.handlers.dispatch :admin, m, "`#{m.user.last_nick}` changed their nick to `#{m.user.nick}`.", m.target
    end

    listen_to :quit, method: :listen_quit
    def listen_quit(m)
      #outgoing_mask = "#{m.user.nick}!#{m.user.data[:user]}@#{m.user.data[:host]}"
      return unless config[:admins].logged_in?(m.prefix)
      config[:admins].logout! m.prefix #change back to m.user.mask once fixed in cinch
      @bot.debug "#{m.prefix} has been automagically logged out."
      @bot.handlers.dispatch :admin, m, "`#{m.prefix}` has been logged out because they left the server.", m.target
    end
  end
end
