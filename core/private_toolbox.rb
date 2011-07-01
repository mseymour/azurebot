# -*- coding: UTF-8 -*-

require 'cinch'

class PrivToolbox
  include Cinch::Plugin

  match %r{say (#\S+) (.+)}, method: :say, use_prefix: false
  match %r{act (#\S+) (.+)}, method: :act, use_prefix: false
  match %r{cs (.+)}, method: :cs, use_prefix: false
  match %r{ns (.+)}, method: :ns, use_prefix: false
  match %r{hs (.+)}, method: :hs, use_prefix: false
	react_on :private

  def check_user(user)
    user.refresh # be sure to refresh the data, or someone could steal
                 # the nick
    config[:admins].include?(user.authname)
  end

  def say(m, channel, text)
    return unless check_user(m.user)
    Channel(channel).send(text)
  end

  def act(m, channel, text)
    return unless check_user(m.user)
    Channel(channel).action(text)
  end

  def cs(m, text)
    return unless check_user(m.user)
    User("chanserv").send(text)
  end

  def ns(m, text)
    return unless check_user(m.user)
    User("nickserv").send(text)
  end

  def hs(m, text)
    return unless check_user(m.user)
    User("hostserv").send(text)
  end

end