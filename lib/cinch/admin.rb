module Cinch
  module Admin
    @@types = { admin: %w{o}, trusted: %w{o h v} }

    def is_admin? (user)
      cc = Channel(shared[:controlchannel])
      cc.users.member?(user) &&
        cc.users[user].any? {|mode| @@types[:admin].include? mode } &&
        user.authed?
    end

    def is@@trusted? (user)
      cc = Channel(shared[:controlchannel])
      cc.users.member?(user) &&
        cc.users[user].any? {|mode| @@types[:trusted].include? mode } &&
        user.authed?
    end
  end
end

__END__

def check_user(users, user)
  modes = @bot.irc.isupport["PREFIX"].keys
  modes.delete("v")
  modes.any? {|mode| users[user].include?(mode)}
end