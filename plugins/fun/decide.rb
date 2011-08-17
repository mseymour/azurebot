# -*- coding: UTF-8 -*-

require_relative '../_ext/string'

class Decide
  include Cinch::Plugin

	match %r{decide (.+)}, method: :execute_decision
	match %r{choose (.+)}, method: :execute_decision
	match %r{coin$}, method: :execute_coinflip

	def decide!(list)
		list = list.irc_strip_colors
		options = list.gsub(/ or /i, ",").split(",").map(&:strip).reject(&:empty?)
		options[Random.new.rand(1..options.length)-1]
	end

	def execute_decision(m, list)
		m.safe_reply("I choose \"#{decide! list}\"!",true);
	end
	
	def execute_coinflip(m)
		face = Random.new.rand(1..2) == 1 ? "heads" : "tails";
		m.safe_reply("I choose \"#{face}\"!",true);
	end

end