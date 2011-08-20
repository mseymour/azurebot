# -*- coding: UTF-8 -*-
require_relative '../ext/string'

module Plugins
  class Kickban
    include Cinch::Plugin
    set(
      plugin_name: "Kickban", 
      help: "Various commands used for kickbanning users.\nUsage: `!moon [nick]` -- kicks the selected user with a My Little Pony: Friendship Is Magic-themed kick reason.\nUsage: `!sun` -- Kickbans the selected user [MLP-themed]\nUsage: `!banana` -- Kicks too. Don't ask.",
      react_on: :channel)

    def check_user(users, user)
      ["h", "o", "a", "q"].any? {|mode| users[user].include?(mode)}
    end

    match /moon (.+)/, method: :moonkick
  	def moonkick(m, nick)
  		return unless check_user(m.channel.users, m.user)
  		baddie = User(nick);
  		#m.channel.ban(baddie.mask("*!*@%h"));
  		m.channel.kick(nick, "#{m.user.nick} banishes #{baddie.nick} to the moon for 1000 years!");
  	end

    match /sun (.+)/, method: :sunban
    def sunban(m, nick)
      return unless check_user(m.channel.users, m.user)
      baddie = User(nick);
      m.channel.ban(baddie.mask("*!*@%h"));
      m.channel.kick(nick, "#{m.user.nick} banishes #{baddie.nick} to the sun, ![b]PERMANENTLY!![b]".irc_colorize);
    end

    match /banana (.+)/, method: :bananakick
    def bananakick(m, nick)
      return unless check_user(m.channel.users, m.user)
      baddie = User(nick);
      m.channel.kick(nick, "#{m.user.nick} banishes #{baddie.nick} TO THE MOOOOOOOOOOOOOOOOOOOOONAAAAAAAAAAAAAAA BEEEYATCH!!!");
    end

  end
end