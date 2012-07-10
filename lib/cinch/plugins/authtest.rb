require_relative "../admin"

module Cinch
  module Plugins
    class Authtest
      include Cinch::Plugin
      include Cinch::Admin
      set(
        plugin_name: "Admin auth checker",
        help: "Tells you if you are logged into the bot or not. (Admins/Trusted only)",
        prefix: /^/,
        suffix: /\?$/)

      match /Am I (an admin|trusted)/i
      def execute(m, question_context)
        test = (question_context.eql?("an admin") ? is_admin?(m.user) : is_trusted?(m.user))
        if test
          #m.channel.action "hugs #{m.user.nick}" if m.channel?
          m.reply "You are #{question_context}!"
        else
          m.reply "Sorry to say this #{m.user.nick}, but you are not #{question_context}."
        end
      end
    end
  end
end
