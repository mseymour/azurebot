# -*- coding: UTF-8 -*-

require 'cinch'

class Toolbox
  include Cinch::Plugin

	prefix /^~/
  match /join (.+)/, method: :join
  match /part(?: (.+))?/, method: :part
  match /quit(?: (.+))?/, method: :quit
	match /nick (.+)/, method: :nick
	#match /opadmin$/, method: :opadmin

  def check_user(user)
    user.refresh # be sure to refresh the data, or someone could steal
                 # the nick
    config[:admins].include?(user.authname)
  end

  def join(m, channel)
    return unless check_user(m.user)
    Channel(channel).join
  end

  def part(m, channel)
    return unless check_user(m.user)
    channel ||= m.channel
    Channel(channel).part if channel
  end

  def quit(m, msg)
    return unless check_user(m.user)
		msg ||= nil
    bot.quit(msg)
  end

	def nick(m, nick)
		return unless check_user(m.user)
		bot.nick=(nick) if nick
	end

  #def opadmin(m)
		#return unless check_user(m.user)
		#m.channel.op(m.user);
  #end

end