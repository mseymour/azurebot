module Cinch
  module Helpers  
    # Determines if the requested channel is on the plugin's disabled list
    # @param c [Channel, String] A Channel object or String
    def is_channel_disabled?(c)
      c = Channel(c) if !c.is_a?(Channel) # Converts input into a Channel unless the input is a Channel object itself
      if config[:disabled_channels]
        config[:disabled_channels].any? {|chan| (c <=> Channel(chan)) == 0 }
      else
        return false
      end
    end
  end
end