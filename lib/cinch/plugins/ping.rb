module Cinch
  module Plugins
    class Ping
      include Cinch::Plugin
      set(
        plugin_name: "Ping",
        help: "Pings you or a target via CTCP, and reports the number of milliseconds on recieving a response.\nUsage: `!ping [nick]`")

      attr_accessor :listen_for_ping

      def initialize(*args)
        super
        @listen_for_ping = {}
      end

      match /ping(?: (\S+))?/, react_on: :channel, group: :x_ping
      def execute(m, nick=nil)
        nick ||= m.user.nick
        user = User(nick)
        return m.reply "You cannot make me ping myself!" if user == @bot
        user = m.user if user.unknown?
        t = Time.now
        user.ctcp("PING #{t.to_i}")
        @listen_for_ping[user.nick] = {target: (m.channel? ? m.channel : m.user), ts: t}
        Timer(5, shots: 1) {
          if @listen_for_ping.has_key?(user.nick)
            m.channel.msg "I could not determine #{user.nick}#{user.nick[-1].casecmp("s") == 0 ? "'" : "'s"} ping to me after 5 seconds."
            @listen_for_ping.delete(user.nick)
          end
        }
      end

      ctcp :ping
      def ctcp_ping(m)
        return unless  @listen_for_ping.has_key?(m.user.nick) && @listen_for_ping[m.user.nick][:ts].to_i == m.ctcp_args[0].to_i
        @listen_for_ping[m.user.nick][:target].msg "#{m.user.nick}#{m.user.nick[-1].casecmp("s") == 0 ? "'" : "'s"} ping to me on #{@bot.irc.isupport['NETWORK']} is #{((Time.now - @listen_for_ping[m.user.nick][:ts]) * 1000).round}ms."
        @listen_for_ping.delete(m.user.nick)
      end
    end
  end
end
