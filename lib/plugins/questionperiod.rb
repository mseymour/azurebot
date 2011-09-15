require 'cgi'

module Plugins
  class QuestionPeriod
    include Cinch::Plugin
    set(
      help: "The bot knows all.",
      prefix: /^/,
      suffix: /\?+?$/)
      
    match /What is (?:a )?(?:"|')?(.+)(?:"|')?/i, method: :execute_whatis
    def execute_whatis m, question
      m.reply "#{m.user.nick}, how about you try <http://lmgtfy.com/?q=#{CGI.escape question}>?"
    end
  end
end