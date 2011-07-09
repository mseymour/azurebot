# -*- coding: UTF-8 -*-

#12:15:40
#12:33:46
require_relative '../_ext/string'

class WarriorBattle
	include Cinch::Plugin
	match /battle\s?(.+)?/
	
	@@MAXHP = 256
	@@MAXHIT = 32
	@@ROUNDS = 8
	
	def start_round! target, user, bot
		# The Kami
		r = Random.new
		
		# HP and rounds
		user_hp = @@MAXHP
		user_rounds_won = 0
		
		bot_hp = @@MAXHP
		bot_rounds_won = 0
		
		# Battle mode activated!
		@@ROUNDS.times {|i|
			return "#{user} has been defeated after #{i.succ} rounds! #{bot} is the winner!" if user_hp <= 0
			return "#{bot} has been defeated after #{i.succ} rounds! #{user} is the winner!" if bot_hp <= 0
		
			# Attack
			user_hit = r.rand(0...@@MAXHIT)
			bot_hit = r.rand(0...@@MAXHIT)
			
			victor = if user_hit < bot_hit
				user_rounds_won = user_rounds_won.succ
				user
			elsif bot_hit < user_hit
				bot_rounds_won = bot_rounds_won.succ
				bot
			else
				"It's a tie"
			end
			
			# subtracting the hit from the combatant's HP's
			bot_hp = bot_hp - bot_hit
			user_hp = user_hp - user_hit
			
			report = []
			report << ["Round #{i.succ.to_s.rjust(2,"0")}/#{@@ROUNDS} report:", user, "vs", bot, "(maximum hit strength: #{@@MAXHIT})"].join(" ")
			report << ["#{user}:".rjust(31), "HP:#{user_hp.to_s.rjust(@@MAXHP.to_s.length)}/#{@@MAXHP}", "Hit:#{user_hit.to_s.rjust(@@MAXHIT.to_s.length)}/#{@@MAXHIT}", "Won:#{user_rounds_won.to_s.rjust(3)}"].join("\t")
			report << ["#{bot}:".rjust(31), "HP:#{bot_hp.to_s.rjust(@@MAXHP.to_s.length)}/#{@@MAXHP}", "Hit:#{bot_hit.to_s.rjust(@@MAXHIT.to_s.length)}/#{@@MAXHIT}", "Won:#{bot_rounds_won.to_s.rjust(3)}"].join("\t")
			report << ["Victor:".rjust(31), victor].join("\t")
			
			puts report.join "\n\t"
				
			target.notice("Round #{i.succ} of #{@@ROUNDS}: #{user} [#{user_hp}/#{@@MAXHP}] versus #{bot} [#{bot_hp}/#{@@MAXHP}] ... #{victor} wins!")
			sleep 2
		}
		overall_victor = if user_rounds_won > bot_rounds_won
			user
		elsif bot_rounds_won > user_rounds_won
			bot
		else
			"It's a tie"
		end
		puts "\tOverall victor: #{overall_victor}!"
		"#{user} (#{user_rounds_won}) versus #{bot} (#{bot_rounds_won})... Overall victor: #{overall_victor}!"
	end
	
	def execute m, u
		u = m.user.nick if u.nil? || u.among_case?(@bot.nick);
		
		m.reply(start_round!(m.user, u, @bot.nick))
	end
end