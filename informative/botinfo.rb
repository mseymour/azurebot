# -*- coding: UTF-8 -*-
require 'cinch'
require 'active_support'
require 'active_support/core_ext'
require_relative '../_ext/irc_color'

class BotInfo
  include Cinch::Plugin
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
  
  def format_notice!
		plugin_list = [];
		@bot.plugins.each {|p| plugin_list << p.class.name.split('::')[-1] };
		
    template = open(config[:template], &:read).gsub(/<(\w+)>/, "%<#{'\1'.downcase}>s").split("\n").delete_if {|d| d =~ /^#.+/}.reject(&:blank?).join("\n");
		
    template % {
      :bot_name => $nick,
			:owner_name => config[:owner],
      :cinch_version => Cinch::VERSION,
      :uptime => time_diff_in_natural_language(@bot.signed_on_at, Time.now),
      :session_start_date => @bot.signed_on_at.strftime("%A, %B %e, %Y, at %l:%M:%S %P"),
      :plugins => plugin_list.to_sentence
    }
  end


  def time_diff_in_natural_language(from_time, to_time)
    # TODO: cite the source of the method
    # TODO: Move this function to a separate file in ../_ext/ and have it a method of the Date class with an argument of "to_time".
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_seconds = ((to_time - from_time).abs).round
    components = []

		%w(year month day hour minute second).map do |interval|
			distance_in_seconds = (to_time.to_i - from_time.to_i).round(1)
			delta = (distance_in_seconds / 1.send(interval)).floor
			delta -= 1 if from_time + delta.send(interval) > to_time
			from_time += delta.send(interval)
			components << "#{delta} #{delta > 1 ? interval.pluralize : interval}" if delta > 0
    end
    components.join(", ")
  end

  def execute(m)
    unless m.user.nick == bot.nick
      m.user.notice(format_notice!.irc_colorize)
    end
  end

end