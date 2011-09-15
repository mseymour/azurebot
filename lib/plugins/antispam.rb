module Plugins
  class AntiSpam
    include Cinch::Plugin

    set help: "Kicks those who spam prefixed bot commands.", required_options: [:limit_seconds, :limit_commands]

    attr_reader :abusers

    def initialize *args
      super
      @abusers = {}
      @@abusee = Struct.new :abuse_count, :first_message_time
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
      return unless m.message.match /^(!|\.|%)/
      if @abusers.has_key?(m.user.nick)
        
        abuser = @abusers[m.user.nick]
        abuser[:abuse_count] = abuser[:abuse_count].succ
        @bot.debug "Abuse count: %d; First message time: %s" % [@abusers[m.user.nick][:abuse_count], @abusers[m.user.nick][:first_message_time].to_s]
        
        if abuser[:abuse_count] >= config[:limit_commands] && (Time.now - abuser[:first_message_time]) <= config[:limit_seconds]
          @bot.debug "Abuse count: %d; command limit: %d; limit seconds: %d; time passed: %d" % [abuser[:abuse_count], config[:limit_commands], config[:limit_seconds], (Time.now - abuser[:first_message_time])]
          @kicks = @kicks.succ
          m.channel.kick(m.user.nick, "Please do not spam bot commands. (#{@kicks})")
          delete_abuser! m.user.nick
          @bot.debug "abUser deleted from kick."
        elsif abuser[:abuse_count] < config[:limit_commands] && (Time.now - abuser[:first_message_time]) > (config[:limit_seconds])
          @abusers.delete(m.user.nick)
          @bot.debug "abUser deleted on good behaviour"
        else
          @bot.debug "abUser - other event."
          if abuser[:abuse_count] >= config[:limit_commands]
            @kicks = @kicks.succ
            m.channel.kick(m.user.nick, "Please do not spam bot commands. (#{@kicks})") 
            delete_abuser! m.user.nick
            @bot.debug "abUser deleted from kick."
          end
        end

      else
        @abusers[m.user.nick] = @@abusee.new(0, Time.now)
        @bot.debug "Abuse count: %d; First message time: %s" % [@abusers[m.user.nick][:abuse_count], @abusers[m.user.nick][:first_message_time].to_s]
      end
    end

  end
end