# -*- coding: UTF-8 -*-

require 'active_support/core_ext'
require_relative '../ext/string'
require_relative '../modules/stringhelpers'

class BotInfo
  include Cinch::Plugin
  include StringHelpers

  set(
    plugin_name: "botinfo",
    help: "Notices you information about me.\nUsage: !#{$nick}",
    required_options: [:template, :owner, :admins])

    match /retrieve plugin classes/, method: :e_rpc
    def e_rpc m
      require 'ap'
      puts "\n"
      @bot.plugins.each {|p| 
        puts "#{p.class.plugin_name} (#{p.class.name}) ".ljust(80,"-")
        ap p.class.methods - Object.methods - Kernel.methods
        #ap p.class.help_message
        #plugin_list << p.class.plugin_name
      };
      puts "\n"
    end


  # How to config:
  # :admin -- admin class instance
  # :template -- a path to a textual file (such as *.txt) with fields in it.
  # :owner -- What to display for the "owner_name" field.
  # All fields in the text file must be surrounded by '<>', and lines can be commented out using '#'.

  match /#{$nick}$/i
  # $nick is a global variable defined in the bot's startup script, above all
  # other requires. In a later version of Cinch, this global variable may be
  # removed in favour of internal functionality.

  def format_notice! user
    plugin_list = [];
    @bot.plugins.each {|p| 
      #require 'ap'
      #ap p.class.methods - Object.methods - Kernel.methods
      #ap p.class.help_message
      #ap p.class.matchers
      plugin_list << p.class.plugin_name
    };

    template = open(config[:template], &:read).gsub(/<(\w+)>/, "%<#{'\1'.downcase}>s").split("\n").delete_if {|d| d =~ /^#.+/}.reject(&:blank?).join("\n");

    template % {
      :bot_name => $nick,
      :owner_name => config[:owner],
      :cinch_version => Cinch::VERSION,
      :is_admin => config[:admins].is_admin?(user.mask) ? "an admin" : "not an admin",
      :uptime => time_diff_in_natural_language(@bot.signed_on_at, Time.now),
      :session_start_date => @bot.signed_on_at.strftime("%A, %B %e, %Y, at %l:%M:%S %P"),
      :plugins => plugin_list.to_sentence,
      :ruby_version => RUBY_VERSION,
      :ruby_platform => RUBY_PLATFORM,
      :ruby_release_date => RUBY_RELEASE_DATE
    }
  end

  def execute(m)
    unless m.user.nick == bot.nick
      m.user.notice(format_notice!(m.user).irc_colorize)
    end
  end

end