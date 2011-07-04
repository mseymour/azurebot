# -*- coding: UTF-8 -*-

require 'cinch'
require_relative '../_ext/irc_color'

class Dongs
  include Cinch::Plugin
	plugin "dongs"
	help "dongs -- My master tells you to go eat a bowl of dick."

	match /r([i]+)dgeracer$/, method: :ridgeracer
	match /w([i]+)deface$/, method: :wideface
	match /dongs$/, method: :execute
	match /dongs (\d+)$/, method: :execute_multiple

	def dong
		dicklength = rand(20)+4;
		dickcolor = rand(15+1);
		"![c#{dickcolor.to_s.rjust(2,"0")}]8#{"=" * dicklength}D".irc_colorize;
	end

  def ridgeracer(m, i)
		m.reply("RIIII#{"II" * i.length}DGE RACER!", false);
  end

  def wideface(m, i)
		m.reply(i.length < 25 ? "('____#{"__" * i.length}'X)" : "WE MUST GO WIDER!", false);
  end

  def execute(m)
		m.reply(dong, false);
  end

  def execute_multiple(m, d)
		if d.to_i == 37
			m.reply("37")
			sleep 1
			m.reply("My girlfriend sucked 37 dicks")
		elsif d.to_i > 5
			#m.reply("More than 37 dicks? Are you CRAZY man?!",true)
			m.reply("More than 5 dongs is way too much, man.",true)
			return;
		elsif d.to_i == 0
			m.reply("If you didn't want any dongs, then why did you ask?",true)
		elsif d.to_i == -1
			m.reply("No infinite dongs for you.",true)
		elsif d.to_i <= -2
			m.reply("...What?",true)
		else
		d.to_i.times do
			m.reply(dong, false);
			sleep 0.10;
		end
		end
  end
end