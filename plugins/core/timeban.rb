require 'cinch'
require 'time'
require 'active_support/core_ext'
require_relative '../../modules/stringhelpers'
require_relative '../../modules/timeban'

class Timeban
	include Cinch::Plugin
	include StringHelpers
	include Timebans
	
	BANMASK = "*!*@%h"
	
	react_on :channel
	
  def check_user(users, user)
    user.refresh # be sure to refresh the data, or someone could steal the nick
    ["h", "o", "a", "q"].any? {|mode| users[user].include?(mode) } ## ←
  end
	
  timer 5, method: :timed
  def timed
		hostnames = Timebans::unbanned?
		hostnames.each_pair {|c, m|
			Channel(c).unban(m)
			Timebans::remove_ban! c, m
		}
  end
	
	match /timeban ((\d+)(s|m|h|d))?\s?([\w\/\[\]\|]+)\s?(.+)?/, method: :set_timeban
	def set_timeban(m, full_length, length, length_unit, nick, reason)
		return unless check_user(m.channel.users, m.user)
		return unless check_user(m.channel.users, User(@bot.nick))
		outlaw = User(nick)
		return m.reply("That's not a user...") if outlaw.unknown?
		hostname = outlaw.mask BANMASK
		date_banned = Time.now
		date_unbanned = case length_unit
			when "s"
				Time.now + length.to_i.second
			when "m"
				Time.now + length.to_i.minute
			when "h"
				Time.now + length.to_i.hour
			when "d"
				Time.now + length.to_i.day
			else
				nil
		end
		
		kickreason = []
		kickreason << "banned"
		kickreason << (!full_length.blank? ? "for #{time_diff_in_natural_language(date_banned, date_unbanned)}" : "indefinitely") << "by #{m.user.nick}"
		kickreason << (!reason.blank? ? "- #{reason}" : "")
		kickreason = kickreason.reject(&:blank?).join(" ")
		
		m.channel.ban(hostname)
		m.channel.kick(outlaw, kickreason)
		
		a_ban = Ban.new(
			:channel => m.channel.name,
			:hostname => hostname,
			:datebanned => date_banned,
			:dateunbanned => date_unbanned,
			:reason => reason,
			:bannedby => m.user.mask
		)
		a_ban.save
	end

	match /unban (.+)/, method: :unban
	def unban m, h
		m.channel.unban h
		Timebans::remove_ban m.channel.name, h
		m.reply "*pouts*"
	end
	
	match /banlist/, method: :listbans
	def listbans m
		banlist = Ban.all(:channel => m.channel.name)
		if !banlist.blank?
			m.reply "Banlist: hostname, time banned, time unbanned, reason, banned by"
			banlist.each {|e| m.reply "#{e.hostname}, #{e.datebanned.to_s}, #{e.dateunbanned}, #{e.reason}, #{e.bannedby}" }
		else
			m.reply "There are no timed bans for #{m.channel.name}."
		end
	end

end