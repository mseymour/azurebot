# -*- coding: UTF-8 -*-

require 'cinch'
require_relative '../_ext/irc_color'

class Rainbow
  include Cinch::Plugin
	plugin "rainbow"
	help "rainbow -- gaaaaaaay."
	
	match /rainbow (.+)$/

	def execute(m, string)
		colour = %w{04 07 08 09 10 06 13}
		i = Random.new.rand(0..colour.size-1);
		new_string = ""
		string.each_char {|c| 
			new_string << "![c#{colour[i]}]#{c}"; 
			i = i < colour.size-1 ? i.next : 0; 
		}
		m.reply(new_string.irc_colorize,false);
	end
end