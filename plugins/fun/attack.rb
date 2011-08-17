# -*- coding: UTF-8 -*-

require_relative '../_ext/string'
require 'yaml'

class Attack
  include Cinch::Plugin
	
	react_on :channel
	match /attack\s?(.+)?/

	def initialize *args
		@@attackdict = []
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
		
	def execute (m, target)
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