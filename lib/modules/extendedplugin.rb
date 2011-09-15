module Plugins
  module DisableFilter
    include Cinch::Plugin
    attr_writer :disabled_channels
      
    match /(dis|en)able (.+)/, method: :execute_disable_plugin_for_channel
    def execute_disable_plugin_for_channel m, type, plugin_name
      return unless m.channel?
      return unless plugin_name == @plugin_name

      case type
      when "dis"
        @disabled_channels << m.channel.name
      when "en"
        @disabled_channels.delete m.channel.name
      end
      m.reply "#{@plugin_name} has been #{type}abled!", true
    end

    def disabled? channel_name
      @disabled_channels.include? channel_name
    end
  end
end