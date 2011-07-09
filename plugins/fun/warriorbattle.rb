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
	
	def execute m, u
		u = m.user.nick if u.nil? || u.among_case?(@bot.nick);
		
		# The Kami
		r = Random.new
		
		# Our combatant
		#user = User(u)
		
		# HP and rounds
		user_hp = @@MAXHP
		user_rounds_won = 0
		
		bot_hp = @@MAXHP
		bot_rounds_won = 0
		
		# Battle mode activated!
		@@ROUNDS.times {|i|
			# Attack
			user_hit = r.rand(0...@@MAXHIT)
			bot_hit = r.rand(0...@@MAXHIT)
			
			victor = if user_hit < bot_hit
				user_rounds_won = user_rounds_won.succ
				u
			elsif bot_hit < user_hit
				bot_rounds_won = bot_rounds_won.succ
				@bot.nick
			else
				"both combatants (a tie)"
			end
			
			# subtracting the hit from the combatant's HP's
			bot_hp = bot_hp - bot_hit
			user_hp = user_hp - user_hit
			
			report = []
			report << ["Round #{i.to_s.rjust(2,"0")} report:", u, "vs", @bot.nick, "(maximum hit strength: #{@@MAXHIT})"].join(" ")
			report << ["#{u}:".rjust(31), "HP:#{user_hp.to_s.rjust(@@MAXHP.to_s.length)}/#{@@MAXHP}", "Hit:#{user_hit.to_s.rjust(@@MAXHIT.to_s.length)}/#{@@MAXHIT}", "Won:#{user_hit.to_s.rjust(3)}"].join("\t")
			report << ["#{@bot.nick}:".rjust(31), "HP:#{bot_hp.to_s.rjust(@@MAXHP.to_s.length)}/#{@@MAXHP}", "Hit:#{bot_hit.to_s.rjust(@@MAXHIT.to_s.length)}/#{@@MAXHIT}", "Won:#{bot_hit.to_s.rjust(3)}"].join("\t")
			report << ["Victor:".rjust(31), victor].join("\t")
			
			puts report.join "\n\t"
			
			m.user.notice("Round #{i.succ}: #{u} [#{user_hp}/#{@@MAXHP}] versus #{@bot.nick} [#{bot_hp}/#{@@MAXHP}] ... #{victor} wins!")
			sleep 2
		}
		overall_victor = if user_rounds_won > bot_rounds_won
			u
		elsif bot_rounds_won > user_rounds_won
			@bot.nick
		else
			"both combatants"
		end
		puts "\tOverall victor: #{overall_victor}!"
		m.reply "#{u} (#{user_rounds_won}) versus #{@bot.nick} (#{bot_rounds_won})... Overall victor: #{overall_victor}!"
	end
end