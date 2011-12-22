module Plugins
  class Authtest
    include Cinch::Plugin
    set(
      plugin_name: "Admin auth checker",
      help: "Tells you if you are logged into the bot or not. (Admins only)",
      prefix: /^/,
      suffix: /\?$/,
      required_options: [:admins])
      
    match /Am I (logged in|an admin)/i
    def execute m, question_context
      test = config[:admins].logged_in? m.user.mask
      if test
        m.channel.action "hugs #{m.user.nick}" if m.channel?
        m.reply "You are #{question_context}!"
      else
        m.reply "Sorry to say this #{m.user.nick}, but you are not #{question_context}."
      end
    end
  end
end