# -*- coding: UTF-8 -*-

module Plugins
  class PrivToolbox
    include Cinch::Plugin
    #include Authenticate

    set(
      plugin_name: "Private toolbox", 
      help: "Bot administrator-only private commands.\nUsage: n/a", 
      required_options: [:admins], 
      react_on: :private)
    
    match %r{^say (#\S+) (.+)}, method: :say, use_prefix: false
    def say(m, channel, text)
      return unless config[:admins].logged_in?(m.user.mask)
      Channel(channel).send(text)
    end

    match %r{^act (#\S+) (.+)}, method: :act, use_prefix: false
    def act(m, channel, text)
      return unless config[:admins].logged_in?(m.user.mask)
      Channel(channel).action(text)
    end

    match %r{^cs (.+)}, method: :cs, use_prefix: false
    def cs(m, text)
      return unless config[:admins].logged_in?(m.user.mask)
      User("chanserv").send(text)
    end

    match %r{^ns (.+)}, method: :ns, use_prefix: false
    def ns(m, text)
      return unless config[:admins].logged_in?(m.user.mask)
      User("nickserv").send(text)
    end

    match %r{^hs (.+)}, method: :hs, use_prefix: false
    def hs(m, text)
      return unless config[:admins].logged_in?(m.user.mask)
      User("hostserv").send(text)
    end

  end
end