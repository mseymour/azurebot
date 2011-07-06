# -*- coding: UTF-8 -*-

require 'cinch'
require_relative '../../modules/authenticate'

class Toolbox
  include Cinch::Plugin
  include Authenticate

	prefix /^~/
  match /join (.+)/, method: :join
  match /part(?: (.+))?/, method: :part
  match /quit(?: (.+))?/, method: :quit
	match /nick (.+)/, method: :nick
	#match /opadmin$/, method: :opadmin

  def join(m, channel)
    return unless Auth::is_admin?(m.user)
    Channel(channel).join
  end

  def part(m, channel)
    return unless Auth::is_admin?(m.user)
    channel ||= m.channel
    Channel(channel).part if channel
  end

  def quit(m, msg)
    return unless Auth::is_admin?(m.user)
		msg ||= nil
    bot.quit(msg)
  end

	def nick(m, nick)
		return unless Auth::is_admin?(m.user)
		bot.nick=(nick) if nick
	end

  #def opadmin(m)
		#return unless Auth::is_admin?(m.user)
		#m.channel.op(m.user);
  #end

end