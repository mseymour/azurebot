require_relative "../helpers/check_user"

module Cinch
  module Plugins
    class AntiSpam
      include Cinch::Plugin
      attr_reader :command_abusers

      class Abuser
        attr_reader :kick_count, :current

        Current = Struct.new(:first_offence, :last_offence, :timer, :count) do          
          def increment_count!
            self.count = self.count.succ
          end
        end
        
        def initialize
          @kick_count = 0
          @current = Current.new(Time.now, Time.now, nil, 1)
        end

        def increment_current!
          @current.increment_count!
          @current.last_offence = Time.now
        end

        def reset_current!
          @current = Current.new(Time.now, Time.now, nil, 1)
        end

        def delete_current_and_increment_kick_count!
          @kick_count, @current = @kick_count.succ, nil
        end
      end

      set plugin_name: 'Anti-spam', help: 'Prevents command spam in channels.', required_options: [:command_threshold, :seconds_threshold, :kick_threshold_for_ban]
      PERIOD_MULTIPLIER = 120

      def initialize(*args)
        super
        @command_abusers = {}
      end

      listen_to :channel, method: :listen_to_spam
      def listen_to_spam(m)
        d = "spam".object_id
        #return if check_user(m.channel, m.user)
        return unless m.message.match(/^[!@%-.\]?]+\w+/)

        if @command_abusers[m.user] # record exists
          record = @command_abusers[m.user]

          record.reset_current! unless record.current

          # The timer will run once after seconds_threshold * PERIOD_MULTIPLIER runs. That is,
          # if seconds_threshold is set to 30, then timer code will run in an hour.
          record.current.timer = Timer(config[:seconds_threshold] * PERIOD_MULTIPLIER, shots: 1) do
            @command_abusers.delete(m.user)
          end

          record.increment_current!
          
          if (record.current.last_offence - record.current.first_offence) <= config[:seconds_threshold] && record.current.count == config[:command_threshold]
            if record.kick_count < config[:kick_threshold_for_ban]
              m.channel.kick(m.user, "You have spammed commands #{record.current.count} times in #{(record.current.last_offence - record.current.first_offence).round(2)} seconds.")
              record.delete_current_and_increment_kick_count!
            else
              m.channel.ban(m.user)
              m.channel.kick(m.user, "You have spammed commands #{record.current.count} times in #{(record.current.last_offence - record.current.first_offence).round(2)} seconds and been kicked #{record.kick_count} times.")
              @command_abusers.delete(m.user) # Erase record after kickban
            end
          elsif (record.current.last_offence - record.current.first_offence) > config[:seconds_threshold]
            # Reset if user ran a command after the threshold
            record.reset_current!
          end
        else # creating a new record
          record = Abuser.new
          #record.current.increment_count!
          record.current.timer = Timer(config[:seconds_threshold] * PERIOD_MULTIPLIER, shots: 1) do
            # Delete abuse record after timer has elapsed.
            @command_abusers.delete(m.user)
          end
          @command_abusers[m.user] = record
        end
        
        @bot.handlers.dispatch :antispam, m, [d,@command_abusers[m.user]], m.target
      end

      match 'antispam status', method: :antispam_status
      def antispam_status(m)
        m.reply "Abusers will be kicked after %d commands within %d seconds, and will be banned after %d kicks.\n" +
                "A 'grace period' of %d minutes is given, after which the abuser's record is deleted, unless they abuse again.\n" +
                "There are currently %d records on %s." % [
                  config[:command_threshold], 
                  config[:seconds_threshold], 
                  config[:kick_threshold_for_ban], 
                  (config[:seconds_threshold] * PERIOD_MULTIPLIER) / 60, 
                  command_abusers.size, 
                  @bot.irc.network.name
                ]
      end

    end
  end
end
