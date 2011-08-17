# -*- coding: UTF-8 -*-
# A colourful version of !8ball.

require_relative '../_ext/string'

class Eightball
  include Cinch::Plugin
	
	react_on :channel
	match /8ball (.+)/
		
		@@type = {
			:sa => 2,
			:ta => 3,
			:nc => 7,
			:ng => 4
		}
		
		@@eightball = [
			["It is certain",:sa],
			["It is decidedly so",:sa],
			["Without a doubt",:sa],
			["Yes - definitely",:sa],
			["You may rely on it",:sa],
			["As I see it, yes",:ta],
			["Most likely",:ta],
			["Outlook good",:ta],
			["Signs point to yes",:ta],
			["Yes",:ta],
			["Reply hazy, try again",:nc],
			["Ask again later",:nc],
			["Better not tell you now",:nc],
			["Cannot predict now",:nc],
			["Concentrate and ask again",:nc],
			["Don't count on it",:ng],
			["My reply is no",:ng],
			["My sources say no",:ng],
			["Outlook not so good",:ng],
			["Very doubtful",:ng]
		]
	
	def shake!
		@@eightball.shuffle!.sample
	end
		
	def execute (m, s)
		questions = s.split("? ")
		answers = [];
		questions.each {|question|
			question[0] = question[0].upcase
			answer = shake!;
			answers << "\"#{question.delete("?")}?\" ![c#{@@type[answer[1]]}]#{answer[0]}![c]"
		}
		output = answers.join(". ") + "."
		m.reply output.irc_colorize, true
	end

end