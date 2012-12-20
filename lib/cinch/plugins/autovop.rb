#require 'active_support/core_ext/hash/indifferent_access'
require_relative "../helpers/check_user"

module Cinch
  module Plugins
    class AutoVOP
      include Cinch::Plugin

      set plugin_name: "AutoVOP",
          help: "Automatically voices/ops nicks upon join.\nUsage: `!auto(op|voice) [on|off]` -- turns autoop/voice on or off. (Chanops only)",
          react_on: :channel#,
          #required_options: [:enabled_channels]

      # Format for :enabled_channels:
      # {"#channel1" => :voice, "#channel2" => :op}

      def initialize(*args)
        super
        config[:enabled_channels] = {} if !config.has_key?(:enabled_channels) # Create hash for enabled_channels if key doesn't exist in config.
      end
      
      listen_to :connect, method: :on_connect
      def on_connect(m)
        # Convert all string channels to Channel objects.
        config[:enabled_channels].each_with_object({}) {|(k,v), memo| memo[Channel(k)] = v }
      end

      listen_to :join, method: :on_join
      def on_join(m)
        return if m.user == bot || !config[:enabled_channels].has_key?(m.channel)
        sleep 0.5 # In case Chanserv/etc. has already given the user a mode.
        return if check_user(m.channel, m.user, nil) # Return if user was already given a mode via chanserv, etc.
        cmode = config[:enabled_channels][m.channel]
        if cmode == :op
          m.channel.op(m.user)
        elsif cmode == :voice
          m.channel.voice(m.user)
        end
      end

      match /auto(op|voice) (on|off)$/
      def execute(m, type, option)
        return unless check_user(m.channel, m.user, %w{h v})
        state = option == 'on'

        if state
          config[:enabled_channels][m.channel] = type.to_sym
        else
          config[:enabled_channels].delete(m.channel)
        end

        m.reply "Auto#{type} is now #{Format((state ? :green : :red), :bold, option)} for #{Format(:bold,m.channel.name)}."
      end

    end
  end
end