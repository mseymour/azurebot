# -*- coding: UTF-8 -*-

require_relative '../../modules/authenticate'

class PrivToolbox
  include Cinch::Plugin
  include Authenticate

  match %r{say (#\S+) (.+)}, method: :say, use_prefix: false
  match %r{act (#\S+) (.+)}, method: :act, use_prefix: false
  match %r{cs (.+)}, method: :cs, use_prefix: false
  match %r{ns (.+)}, method: :ns, use_prefix: false
  match %r{hs (.+)}, method: :hs, use_prefix: false
	react_on :private

  def say(m, channel, text)
    return unless Auth::is_admin?(m.user)
    Channel(channel).send(text)
  end

  def act(m, channel, text)
    return unless Auth::is_admin?(m.user)
    Channel(channel).action(text)
  end

  def cs(m, text)
    return unless Auth::is_admin?(m.user)
    User("chanserv").send(text)
  end

  def ns(m, text)
    return unless Auth::is_admin?(m.user)
    User("nickserv").send(text)
  end

  def hs(m, text)
    return unless Auth::is_admin?(m.user)
    User("hostserv").send(text)
  end

end