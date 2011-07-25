# -*- coding: UTF-8 -*-

require_relative '../../modules/authenticate'

class Toolbox
  include Cinch::Plugin
  include Authenticate

	prefix /^~/
  match /join (.+)/, method: :join
  match /part(?: (\S+)\s?(.+)?)?/, method: :part
  match /quit(?: (.+))?/, method: :quit
	match /nick (.+)/, method: :nick
	match /opadmin$/, method: :opadmin

  def join(m, channel)
    return unless Auth::is_admin?(m.user)
    channel.split(", ").each {|ch|
      Channel(ch).join
    }
  end

  def part(m, channel, msg)
    return unless Auth::is_admin?(m.user)
    channel ||= m.channel
    msg ||= m.user.nick
    Channel(channel).part(msg) if channel
  end

  def quit(m, msg)
    return unless Auth::is_admin?(m.user)
		msg ||= m.user.nick
    bot.quit(msg)
  end

	def nick(m, nick)
		return unless Auth::is_admin?(m.user)
		bot.nick=(nick) if nick
	end

  def opadmin(m)
		return unless Auth::is_admin?(m.user)
		m.channel.op(m.user.nick);
  end

end