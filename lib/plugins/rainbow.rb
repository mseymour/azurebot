# -*- coding: UTF-8 -*-

require 'obj_ext/string'

module Plugins
	class Rainbow
		include Cinch::Plugin
		
		set plugin_name: "Rainbow", help: "Rainbowificates your text.\nUsage: `!rainbow [text]`.\nUsage: `eyerape [text]`."

		def rainbowification s
			s.irc_strip_colors! # Because total function abuse.
			colour = %w{04 07 08 09 10 06 13}
			i = Random.new.rand(0..colour.size-1);
			new_string = ""
			s.each_char {|c| 
				new_string << "![c#{colour[i]}]#{c}"; 
				i = i < colour.size-1 ? i.next : 0; 
			}
			new_string
		end

		def eyerapeification s
			sd = s.dup
			sd.irc_strip_colors! # Because total function abuse.
			colour = %w{04 07 08 09 10 06 13}
			offset = Random.new.rand(0..colour.size-1);
			sd = "![b]" + sd.upcase.split(" ").map {|c| 
				offset = (offset < colour.size-1 ? offset.next : 0);
				"![c#{colour[offset]},#{colour[offset-4]}]#{c.each_char.each_with_index.map {|char,index| index % 2 == 0 ? char : char.downcase}.join}"
			}.join(" ")
			#sd
		end

		match /rainbow (.+)$/, method: :execute_rainbow
		def execute_rainbow (m, string); m.reply(rainbowification(string).irc_colorize,false); end;

		match /eyerape (.+)$/, method: :execute_eyerape
		def execute_eyerape (m, string); m.reply(eyerapeification(string).irc_colorize,false); end;

	end
end