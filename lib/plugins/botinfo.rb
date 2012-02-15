# -*- coding: UTF-8 -*-
require 'tag_formatter'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/array/conversions'
require_relative '../obj_ext/string'
require_relative '../modules/stringhelpers'

module Plugins
  class BotInfo
    include Cinch::Plugin
    include StringHelpers

    set(
      plugin_name: "Botinfo",
      help: "Notices you information about me.\nUsage: `/msg <nick> info`\nUsage: `/msg <nick> list plugins`",
      required_options: [:template_path, :owner, :bot, :admins],
      react_on: :private)

    # How to config:
    # :admin -- admin class instance
    # :template -- a path to a textual file (such as *.txt) with fields in it.
    # :owner -- What to display for the "owner_name" field.
    # :bot -- What to display for the "bot_name" field.
    # All fields in the text file must be surrounded by '<>', and lines can be commented out using '#'.

    match /^info$/i, use_prefix: false
    def execute(m)
      tags = {
        bot_name: @bot.nick,
        cinch_version: Cinch::VERSION,
        is_admin: config[:admins].is_admin?(m.user.mask) ? "an admin" : "not an admin",
        owner_name: config[:admins].first_nick || config[:owner],
        plugins_count_remaining: @bot.plugins.length - 9,
        plugins_head: @bot.plugins[0..9].map {|p| p.class.plugin_name }.join(", "),
        ruby_platform: RUBY_PLATFORM,
        ruby_release_date: RUBY_RELEASE_DATE,
        ruby_version: RUBY_VERSION,
        session_start_date: @bot.signed_on_at.strftime("%A, %B %e, %Y, at %l:%M:%S %P"),
        total_channels: "(SOON)",
        total_users: "(SOON)",
        uptime: time_diff_in_natural_language(@bot.signed_on_at, Time.now, acro: true)
      }
      
      tf = TagFormatter.new open(config[:template_path],&:read), tags: tags

      m.user.notice tf.parse!
    end

    match /list plugins$/i, method: :execute_list, use_prefix: false
    def execute_list m
      list = []
      @bot.plugins.each {|p| list << p.class.plugin_name };
      m.user.notice("All #{list.size} currently loaded plugins for #{@bot.nick}:\n#{list.to_sentence}.\nTo view help for a plugin, use `!help <plugin name>`.")
    end

  end
end