require 'time'
require 'active_support/core_ext/object/blank'

module Plugins
  class Ping
    include Cinch::Plugin

    attr_accessor :listen_for_ping

    def initialize *args
      super
      @listen_for_ping = {}
    end

    match /ping(?:\s(\S+))?/i
    def execute m, nick
      nick = m.user.nick if nick.blank?
      return m.reply "You cannot make me ping myself!" if nick.casecmp(@bot.nick) == 0
      user = User((nick if !User(nick).unknown?) || m.user.nick)
      t = Time.now
      user.ctcp("PING #{t.to_i}")
      @listen_for_ping[user.nick] = {target: (m.channel? ? m.channel : m.user), ts: t}
    end

    ctcp :ping
    def ctcp_ping(m)
      return unless  @listen_for_ping.has_key?(m.user.nick) && @listen_for_ping[m.user.nick][:ts].to_i == m.ctcp_args[0].to_i
      @listen_for_ping[m.user.nick][:target].msg "#{m.user.nick}#{m.user.nick[-1].casecmp("s") == 0 ? "'" : "'s"} ping to me on #{@bot.config.server} is #{((Time.now - @listen_for_ping[m.user.nick][:ts]) * 1000).round}ms."
      @listen_for_ping.delete(m.user.nick)
    end
  end
end