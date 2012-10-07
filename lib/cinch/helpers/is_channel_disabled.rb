module Cinch
  module Helpers  
    # Determines if the requested channel is on the plugin's disabled list
    # @param c [Channel, String] A Channel object or String
    def is_channel_disabled?(c)
      c = Channel(c) if !c.respond_to?(:name) # Converts input into a Channel unless the input is a Channel object itself
      if config.has_key?(:disabled_channels)
        config[:disabled_channels].any? {|chan| c == Channel(chan) }
      end
    end
  end
end