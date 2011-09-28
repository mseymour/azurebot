# -*- coding: UTF-8 -*-

require 'active_support/core_ext'
require 'obj_ext/string'
require 'modules/stringhelpers'

module Plugins
  class BotInfo
    include Cinch::Plugin
    include StringHelpers

    set(
      plugin_name: "botinfo",
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

      match /generate documentation/, method: :e_rpc # Yes, I know that the command is a misnomer. 
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
          documentation << "### #{p.class.plugin_name} (`#{p.class.name}`)"
          documentation << ""
          documentation << (!p.class.help.blank? ? "#{p.class.help.gsub("\n","\n\n")}" : "(No help available)")
          documentation << ""
        };

        documentation << "Commands"
        documentation << "--------"
        documentation << ""
        documentation << "As a note, all commands shown here are generated from the plugin's matches, composited with their individual prefices and suffices (if applicable.)"
        documentation << ""
        @bot.plugins.each {|p| 
          documentation << "### #{p.class.plugin_name} (`#{p.class.name}`)"
          documentation << ""

          p.class.matchers.each {|m|
            prefix = regexp_process p.class.prefix, @bot.config.plugins.prefix if m.use_prefix
            suffix = regexp_process p.class.suffix, @bot.config.plugins.suffix if m.use_suffix
            pattern = regexp_process m.pattern

            documentation << "* `#{prefix}#{pattern}#{suffix}`"
          }
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
        uptime: time_diff_in_natural_language(@bot.signed_on_at, Time.now),
        session_start_date: @bot.signed_on_at.strftime("%A, %B %e, %Y, at %l:%M:%S %P"),
        plugins: plugin_list.to_sentence,
        ruby_version: RUBY_VERSION,
        ruby_platform: RUBY_PLATFORM,
        ruby_release_date: RUBY_RELEASE_DATE
      }
    end

    match /(.+)$/i
    def execute(m, nick)
      return unless nick.casecmp(config[:bot]) == 0
      m.user.notice(format_notice!(m.user).irc_colorize)
    end

  end
end