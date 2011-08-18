# -*- coding: UTF-8 -*-

require_relative '../ext/string'
require 'yaml'

class Attack
	include Cinch::Plugin
	
	set(
		plugin_name: "Attacker",
		help: "Attacks a user with a random attack.\nUsage: `!attack <nick or phrase>`; `<nick or phrase>` may be omitted for a random attack on a random nick.",
		required_options: [:attack_dictionary],
		react_on: :channel)
	
	def initialize *args
		@@attackdict = []
		@@lastattack = []
		@@cons_attack_count = 0
		super
	end
	
	def populate_attacks!
		@@attackdict.replace YAML::load_file(config[:attack_dictionary]).map {|e| e.gsub(/<(\w+)>/, "%<#{'\1'.downcase}>s") }
	end
	
	def grab_random_nick ( users )
		users.to_a.sample[0].nick;
	end

	def attack! ( target, assailant )
		return nil if target.nil?;
		@@attackdict.sample % {:target => target, :assailant => assailant, :bot => @bot.nick};
	end
	
	def random_attack! ( targets, assailant )
		@@attackdict.sample % {:target => grab_random_nick(targets), :assailant => assailant, :bot => @bot.nick};
	end
	
	match /attack\s?(.+)?/
	def execute (m, target)
		if !@@lastattack.empty? && @@lastattack[0] == m.user.nick
			puts "#{@@lastattack.inspect} | #{@@cons_attack_count}"
			@@cons_attack_count = @@cons_attack_count.succ
			if @@cons_attack_count >= 4 && ((Time.now - @@lastattack[1]) / 60) <= 1
				puts "DIE MONSTER!"
				m.channel.kick(m.user.nick, "Enough of ye!!")
			end
			@@lastattack = [m.user.nick, Time.now]
		elsif !@@lastattack.empty? && @@cons_attack_count[0] != m.user.nick
			puts "#{@@lastattack.inspect} | #{@@cons_attack_count}"
			@@cons_attack_count = 0
			@@lastattack = [m.user.nick, Time.now]
		else
			@@lastattack = [m.user.nick, Time.now]
		end

		target = m.user.nick if !target.nil? && target.among_case?(@bot.nick, "herself", "himself", "itself");
		
		populate_attacks!
		
		output = if target
			attack!(target.irc_strip_colors, m.user.nick)
		else
			random_attack!(m.channel.users, m.user.nick)
		end
		m.channel.action output.irc_colorize;
	end

end