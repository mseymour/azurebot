# -*- coding: UTF-8 -*-

require 'ext/string'

module Plugins
	class Decide
		include Cinch::Plugin
		set(
			plugin_name: "Decider",
			help: "Helps you decide on things.\nUsage: `!decide [a list of items separated by \", \", \", or\", or \" or \"]`; Usage: `!coin`")

		def decide!(list)
			list = list.irc_strip_colors
			options = list.gsub(/ or /i, ",").split(",").map(&:strip).reject(&:empty?)
			options[Random.new.rand(1..options.length)-1]
		end

		match %r{decide (.+)}, method: :execute_decision
		match %r{choose (.+)}, method: :execute_decision
		def execute_decision(m, list)
			m.safe_reply("I choose \"#{decide! list}\"!",true);
		end
		
		match %r{coin$}, method: :execute_coinflip
		def execute_coinflip(m)
			face = Random.new.rand(1..2) == 1 ? "heads" : "tails";
			m.safe_reply("I choose \"#{face}\"!",true);
		end

	end
end