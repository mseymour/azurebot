module Plugins
  class AntiSpam
    include Cinch::Plugin

    set help: "Kicks those who spam prefixed bot commands.", required_options: [:limit_seconds, :limit_commands]

    attr_reader :abusers

    def initialize *args
      super
      @abusers = {}
      @@abuser = Struct.new :abuse_count, :first_message_time, :last_message_time
      @kicks = 0
    end

    def delete_abuser! nick
      @abusers.delete(nick)
    end

    listen_to :kick, method: :listen_to_kick
    def listen_to_kick m
      return unless @abusers.has_key?(m.user.nick)
      delete_abuser! m.user.nick
    end

    listen_to :channel, method: :listen_to_commandspam
    def listen_to_commandspam m
      trec = Time.now.to_i
      message = m.message
      return unless message.match /^[!\.%]/
      if @abusers.has_key? m.user.nick
        if (Time.now - @abusers[m.user.nick][:first_message_time]) <= config[:limit_seconds] && (Time.now - @abusers[m.user.nick][:last_message_time]) <= (config[:limit_seconds] / 2)
            @abusers[m.user.nick][:abuse_count] = @abusers[m.user.nick][:abuse_count].succ
            @abusers[m.user.nick][:last_message_time] = Time.now
            @bot.handlers.dispatch :antispam, m, "35 #{m.user.nick}'s command abuse count has been increased to #{@abusers[m.user.nick][:abuse_count]}.", m.target
          if @abusers[m.user.nick][:abuse_count] >= config[:limit_commands]
            m.channel.kick(m.user)
            @abusers.delete m.user.nick
            @bot.handlers.dispatch :antispam, m, "39 #{m.user.nick} has been kicked and their abuse record deleted.", m.target
          end
        else
          @abusers.delete m.user.nick
          @bot.handlers.dispatch :antispam, m, "43 #{m.user.nick}'s abuse record has been deleted (for good behaviour).", m.target
        end
      else
        @abusers[m.user.nick] = @@abuser.new 1, Time.now, Time.now
        @bot.handlers.dispatch :antispam, m, "47 A new command abuse record has been created for #{m.user.nick}.", m.target
      end
    end

  end
end