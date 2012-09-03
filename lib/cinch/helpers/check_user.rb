module Cinch
  module Helpers  
    # Checks a user's access in the specified channel.
    # @param channel [Channel, String] A Channel object or string that is the name of the channel. (i.e. #chat)
    # @param user [User] A User object
    # @param ignored_members [Array<String>] An array of modes that this method will ignore
    # @return [Boolean] Returns True if the user has any channel modes other than the ignored modechars
    # @author Mark Seymour/Azure <mark.seymour.ns@gmail.com>
    def check_user(channel, user, ignored_members=["v"])
      ignored_members ||= [] # If nil, assign an empty array.
      users = Channel(channel).users # All users from supplied channel
      modes = @bot.irc.isupport["PREFIX"].keys - ignored_members
      modes.any? {|mode| users[user].include?(mode)}
    end
  end
end