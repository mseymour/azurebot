# -*- coding: UTF-8 -*-

class Decide
  include Cinch::Plugin

	match %r{decide (.+)}
	match %r{choose (.+)}

	def decide!(list)
		options = list.gsub(/ or /i, ",").split(",").map(&:strip).reject(&:empty?)
		options[Random.new.rand(1..options.length)-1]
	end

	def execute(m, list)
		m.safe_reply("I choose \"#{decide! list}\"!",true);
	end

end