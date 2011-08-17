# -*- coding: UTF-8 -*-

require_relative '../../modules/authenticate'
require_relative '../../modules/stringhelpers'
#require 'active_support'
require 'active_support/core_ext'
require_relative '../_ext/string'

class BotInfo
  include Cinch::Plugin
  include Authenticate
  include StringHelpers
  
  plugin "botinfo"
  help "!#{$nick} - Notices you information about me."
  
  # How to config:
  # :template -- a path to a textual file (such as *.txt) with fields in it.
  # :owner -- What to display for the "owner_name" field.
  # All fields in the text file must be surrounded by '<>', and lines can be commented out using '#'.

  match /#{$nick}$/i
  # $nick is a global variable defined in the bot's startup script, above all
  # other requires. In a later version of Cinch, this global variable may be
  # removed in favour of internal functionality.
  
  def format_notice! user
		plugin_list = [];
		@bot.plugins.each {|p| plugin_list << p.class.name.split('::')[-1] };
		
    template = open(config[:template], &:read).gsub(/<(\w+)>/, "%<#{'\1'.downcase}>s").split("\n").delete_if {|d| d =~ /^#.+/}.reject(&:blank?).join("\n");
		
    template % {
      :bot_name => $nick,
			:owner_name => Auth::head_admin,
      :cinch_version => Cinch::VERSION,
      :isadmin => Auth::is_admin?(user) ? "an admin" : "not an admin",
      :uptime => time_diff_in_natural_language(@bot.signed_on_at, Time.now),
      :session_start_date => @bot.signed_on_at.strftime("%A, %B %e, %Y, at %l:%M:%S %P"),
      :plugins => plugin_list.to_sentence
    }
  end

  def execute(m)
    unless m.user.nick == bot.nick
      m.user.notice(format_notice!(m.user).irc_colorize)
    end
  end

end