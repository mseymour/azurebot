# -*- coding: UTF-8 -*-

class Eightball
  include Cinch::Plugin
	
	react_on :channel
	match /8ball (.+)/

		@@eightball = [
			"It is certain",
			"It is decidedly so",
			"Without a doubt",
			"Yes - definitely",
			"You may rely on it",
			"As I see it, yes",
			"Most likely",
			"Outlook good",
			"Signs point to yes",
			"Yes",
			"Reply hazy, try again",
			"Ask again later",
			"Better not tell you now",
			"Cannot predict now",
			"Concentrate and ask again",
			"Don't count on it",
			"My reply is no",
			"My sources say no",
			"Outlook not so good",
			"Very doubtful"
		]
	
	def shake!
		@@eightball.shuffle!.sample
	end
		
	def execute (m, s)
		questions = s.split("? ")
		answers = [];
		questions.each {|question|
			question[0] = question[0].upcase
			answers << "\"#{question.delete("?")}?\" #{shake!}"
		}
		output = answers.join(". ") + "."
		m.safe_reply output, true
	end

end