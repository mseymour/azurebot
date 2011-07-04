# -*- coding: UTF-8 -*-

require 'cinch'
require 'pp'

class Kickban
  include Cinch::Plugin

	match /moon (.+)/, method: :ponyban

  def check_user(users, user)
    user.refresh # be sure to refresh the data, or someone could steal the nick
    ["h", "o", "a", "q"].any? {|mode| users[user].include?(mode)}
  end

	def ponyban(m, nick)
		return unless check_user(m.channel.users, m.user)
		baddie = User(nick);
		m.channel.kick(nick, "#{m.user.nick} banishes #{baddie.nick} to the moon for 1000 years!");
		m.channel.ban(baddie.mask("*!*@%h"));
	end

end