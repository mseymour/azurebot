module Cinch
  module Helpers  
    def check_user(channel, user, ignored_members=["v"])
      ignored_members ||= [] # If nil, assign an empty array.
      users = Channel(channel).users # All users from supplied channel
      modes = @bot.irc.isupport["PREFIX"].keys - ignored_members # 
      modes.any? {|mode| users[user].include?(mode)}
    end
  end
end