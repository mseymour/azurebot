require 'json'

module Cinch::Plugins
  class Tell
    include Cinch::Plugin

    set help: "Allows messaging users who are away.\nUsage: !tell <nick> <message>"

    match /tell (\S+) (.+)/, method: :tell
    def tell(m, nick, msg)
      # Unread Set: remind:<network>= [zuzu, plausocks, ...]
      # Individual user's reminder list: remind:<network>:<nick> = [{...}, {...}]
      data = {to: nick, from: m.user.nick, time: Time.now.to_f, msg: msg}
      shared[:redis].sadd "remind:#{@bot.irc.network.name.downcase}", nick.irc_downcase(:rfc1459)
      shared[:redis].rpush "remind:#{@bot.irc.network.name.downcase}:#{nick.irc_downcase(:rfc1459)}", data.to_json
      m.reply "I'll pass that along to #{nick} when they are around.", true
    end

    #listen_to :join, method: :on_activity
    listen_to :channel, method: :on_activity
    def on_activity(m)
      messages = get_unread(m.user.nick)
      if messages
        m.user.msg "Hey #{m.user.nick}! You have #{messages.length > 1 ? "#{messages.length} new messages" : "1 new message"}:"
        messages.each do |ms|
          m.user.msg "%s <%s> tell %s %s" % [Time.at(ms['time']).getutc.strftime('%d %b %H:%M%Z'), ms['from'], ms['to'], ms['msg']]
        end
      end
    end

    def get_unread(nick)
      if shared[:redis].sismember "remind:#{@bot.irc.network.name.downcase}", nick.irc_downcase(:rfc1459)
        key = "remind:#{@bot.irc.network.name.downcase}:#{nick.irc_downcase(:rfc1459)}"
        unread = shared[:redis].lrange key, 0, -1
        shared[:redis].del key
        shared[:redis].srem "remind:#{@bot.irc.network.name.downcase}", nick.irc_downcase(:rfc1459)
        unread.map {|item| JSON.parse(item) }
      end
    end

  end
end