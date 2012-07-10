module Cinch
  module Plugins
    class KeepNick
      include Cinch::Plugin
      set plugin_name: "keepnick", help: "Automatically ghosts the bot's nick on connect and restores it."

      listen_to :connect, method: :on_connect
      def on_connect(m)
        
      end

      match "keepnicktest"
      def execute(m)
      m.reply "My last nick was #{@bot.last_nick}. My current nick is #{@bot.nick}. My default nick is #{@bot.config.nick}. My default nick #{!@bot.nick.irc_downcase(:rfc1459).eql?(@bot.config.nick.irc_downcase(:rfc1459)) || @bot.last_nick.nil? ? "is" : "is not"} the same as my current nick. I #{@bot.config.sasl.password ? "am" : "am not"} using an SASL password."
      end
    end
  end
end