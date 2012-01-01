# -*- coding: UTF-8 -*-

require 'active_support/core_ext'
require 'obj_ext/string'
require 'modules/stringhelpers'

module Plugins
  class BotInfo
    include Cinch::Plugin
    include StringHelpers

    set(
      plugin_name: "Botinfo",
      help: "Notices you information about me.\nUsage: `![botnick]`",
      required_options: [:template, :owner, :bot, :admins])

      def regexp_process (local_r, bot_r = nil)
        if !local_r.blank?
          local_r.is_a?(Regexp) ? local_r.source : local_r.to_s
        elsif !bot_r.blank?
          bot_r.is_a?(Regexp) ? bot_r.source : bot_r.to_s
        else
          ""
        end
      end

      match /generate documentation/, method: :e_rpc # Yes, I know that the command is a misnomer. -e: Not now?
      def e_rpc m
        return unless config[:admins].logged_in?(m.user.mask)

        documentation = []
        documentation << "Azurebot"
        documentation << "========"
        documentation << ""
        documentation << "A Ruby-powered IRC bot using the [Cinch IRC bot framework](https://github.com/cinchrb/cinch \"Cinch at Github\")"
        documentation << ""
        
        documentation << "Plugins"
        documentation << "-------"
        documentation << ""
        @bot.plugins.each {|p| 
          next if p.class.help.blank?
          documentation << "### #{p.class.plugin_name} (`#{p.class.name}`)"
          documentation << ""
          documentation << "#{p.class.help.gsub("\n","\n\n")}"
          documentation << ""
        };

        documentation << "Author information"
        documentation << "------------------"
        documentation << "* Mark Seymour ('Azure')"
        documentation << "* Email: <mark.seymour.ns@gmail.com>"
        documentation << "* WWW: <http://lain.rustedlogic.net/>"
        documentation << "* IRC: #shakesoda @ irc.freenode.net"

        File.open("#{File.expand_path("~")}/azurebot_documentation.md", 'w') {|f| f.write(documentation.join("\n")) }
      end


    # How to config:
    # :admin -- admin class instance
    # :template -- a path to a textual file (such as *.txt) with fields in it.
    # :owner -- What to display for the "owner_name" field.
    # :bot -- What to display for the "bot_name" field.
    # All fields in the text file must be surrounded by '<>', and lines can be commented out using '#'.

    def format_notice! user
      plugin_list = [];
      @bot.plugins.each {|p| 
        plugin_list << p.class.plugin_name
      };

      template = open(config[:template], &:read).gsub(/<(\w+)>/, "%<#{'\1'.downcase}>s").split("\n").delete_if {|d| d =~ /^#.+/}.reject(&:blank?).join("\n");

      template % {
        bot_name: config[:bot],
        owner_name: config[:admins].first_nick || config[:owner],
        cinch_version: Cinch::VERSION,
        is_admin: config[:admins].is_admin?(user.mask) ? "an admin" : "not an admin",
        uptime: time_diff_in_natural_language(@bot.signed_on_at, Time.now, acro: true),
        session_start_date: @bot.signed_on_at.strftime("%A, %B %e, %Y, at %l:%M:%S %P"),
        plugins: plugin_list.to_sentence,
        plugins_head: plugin_list[0..9].join(", "),
        plugin_count_remaining: plugin_list.length - 10,
        ruby_version: RUBY_VERSION,
        ruby_platform: RUBY_PLATFORM,
        ruby_release_date: RUBY_RELEASE_DATE
      }
    end

    match /(.+)$/i
    def execute(m, nick)
      return unless (nick.irc_downcase(:rfc1459) <=> config[:bot].irc_downcase(:rfc1459)) == 0
      m.user.notice(format_notice!(m.user).irc_colorize)
    end

    match /plugins$/i, method: :execute_list
    def execute_list m
      list = []
      @bot.plugins.each {|p| list << p.class.plugin_name };
      m.user.notice("All #{list.size} currently loaded plugins for #{@bot.nick}:\n#{list.to_sentence}.\nTo view help for a plugin, use `!help <plugin name>`.")
    end

  end
end