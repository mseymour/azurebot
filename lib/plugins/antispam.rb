require_relative '../modules/helpers/table_format'

module Plugins
  module AntiSpam
    class Kicker
      include Cinch::Plugin

      set plugin_name: "Antispam Kicker", help: "Kicks those who spam prefixed bot commands.", required_options: [:limit_seconds, :limit_commands]

      attr_reader :abusers

      def initialize(*args)
        super
        @abusers = {}
        @@abuser = Struct.new :abuse_count, :first_message_time, :last_message_time
        @kicks = 0
      end

      def delete_abuser!(nick)
        @abusers.delete(nick)
      end

      listen_to :kick, method: :listen_to_exit
      listen_to :quit, method: :listen_to_exit
      def listen_to_exit(m)
        return unless @abusers.has_key?(m.user.nick)
        delete_abuser! m.user.nick
      end

      listen_to :channel, method: :listen_to_commandspam
      def listen_to_commandspam(m)
        trec = Time.now.to_i
        message = m.message
        return unless message.match(/^[-!\.%\?](?![-!\.%\?]+)/) && message.length > 1
        if @abusers.has_key? m.user.nick
          if (Time.now - @abusers[m.user.nick][:first_message_time]) <= config[:limit_seconds] && (Time.now - @abusers[m.user.nick][:last_message_time]) <= (config[:limit_seconds] / 2)
              @abusers[m.user.nick][:abuse_count] = @abusers[m.user.nick][:abuse_count].succ
              @abusers[m.user.nick][:last_message_time] = Time.now
              #@bot.handlers.dispatch :antispam, m, "#{m.user.nick}'s command abuse count has been increased to #{@abusers[m.user.nick][:abuse_count]}.", m.target
            if @abusers[m.user.nick][:abuse_count] >= config[:limit_commands]
              m.channel.kick(m.user,"You have spammed commands #{@abusers[m.user.nick][:abuse_count]} times in #{(Time.now - @abusers[m.user.nick][:first_message_time]).round(2)} seconds.")
              #m.user.msg "You have used too many bot commands in a short period of time. Cool down and go get a drink, okay?"
              @abusers.delete m.user.nick
              @bot.handlers.dispatch :antispam, m, "#{m.user.nick} has been kicked and their abuse record deleted.", m.target
              #@bot.handlers.dispatch :antispam, m, "#{m.user.nick} has been notified and their abuse record deleted.", m.target
            end
          else
            @abusers.delete m.user.nick
            #@bot.handlers.dispatch :antispam, m, "#{m.user.nick}'s abuse record has been deleted (for good behaviour).", m.target
          end
        else
          @abusers[m.user.nick] = @@abuser.new 1, Time.now, Time.now
          #@bot.handlers.dispatch :antispam, m, "A new command abuse record has been created for #{m.user.nick}.", m.target
        end
      end

      listen_to :antispam_list, method: :listen_to_listabusers
      def listen_to_listabusers(m)
        @bot.handlers.dispatch :antispam_list_response, m, @abusers
      end
    end

    class Lister
      include Cinch::Plugin
      set plugin_name: "Antispam Lister", help: "List those who spam prefixed bot commands.", reacting_on: :private, required_options: [:admins]
      match /^list abusers/, use_prefix: false
      def execute(m)
        @bot.handlers.dispatch :antispam_list, m
      end
      listen_to :antispam_list_response
      def listen(m, abusers)
        return unless config[:admins].logged_in? m.user.mask
        abusers = abusers.to_a.map {|e| "%s\t%d\t%s\t%s" % [e[0], e[1][:abuse_count], e[1][:first_message_time], e[1][:last_message_time]] }
        m.user.msg Helpers::table_format(abusers, gutter: 4, justify: [:left,:right,:left,:left], headers: ["Nick","Abuse count","First Message","Last Message"]), true
      end
    end
  end
end
